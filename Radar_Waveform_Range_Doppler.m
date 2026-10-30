%% STAGE 1: LFM RADAR WAVEFORM GENERATION

clear;
clc;
close all;
%% DEFINE PROJECT FOLDER PATHS

projectFolder = fileparts(mfilename('fullpath'));

figuresFolder = fullfile(projectFolder, 'figures');
resultsFolder = fullfile(projectFolder, 'results');

% Create folders if they do not exist
if ~exist(figuresFolder, 'dir')
    mkdir(figuresFolder);
end

if ~exist(resultsFolder, 'dir')
    mkdir(resultsFolder);
end

%% 1. DEFINE PARAMETERS

B = 20e6;          % Bandwidth: 20 MHz
T = 20e-6;         % Pulse duration: 20 microseconds
fs = 100e6;        % Sampling frequency: 100 MHz

K = B / T;         % Chirp rate
dt = 1 / fs;
t = 0:dt:T-dt;

%% 2. GENERATE LFM CHIRP

tx = exp(1j*pi*K*t.^2);

% Instantaneous frequency
instantaneous_frequency = K*t;

%% 3. SAVE WAVEFORM DATA

waveform_data = table( ...
    t(:), real(tx(:)), imag(tx(:)), ...
    instantaneous_frequency(:), ...
    'VariableNames', {'Time_s', 'InPhase', ...
    'Quadrature', 'InstantaneousFrequency_Hz'});

writetable(waveform_data, ...
    fullfile('results', 'lfm_waveform_data.csv'));

%% 4. PLOT THE CHIRP WAVEFORM

figure;

plot(t*1e6, real(tx), 'LineWidth', 1.2);

xlabel('Time (microseconds)');
ylabel('Amplitude');
title('Transmitted LFM Chirp');
grid on;

saveas(gcf, ...
    fullfile('figures', 'lfm_chirp_waveform.png'));

%% 5. PLOT THE FREQUENCY SWEEP

figure;

plot(t*1e6, instantaneous_frequency/1e6, ...
    'LineWidth', 1.5);

xlabel('Time (microseconds)');
ylabel('Frequency (MHz)');
title('LFM Chirp Instantaneous Frequency');
grid on;

saveas(gcf, ...
    fullfile('figures', 'lfm_frequency_sweep.png'));

%% 6. DISPLAY RESULTS

fprintf('LFM waveform generated successfully.\n');
fprintf('Bandwidth: %.1f MHz\n', B/1e6);
fprintf('Pulse duration: %.1f microseconds\n', T*1e6);
fprintf('Sampling frequency: %.1f MHz\n', fs/1e6);
fprintf('Theoretical range resolution: %.2f metres\n', ...
    3e8/(2*B));

disp('Check the figures and results folders for your files.');
%% STAGE 2: TARGET ECHO AND PULSE COMPRESSION

% Radar parameters
c = 3e8;                 % Speed of light (m/s)
target_range = 1500;     % Simulated target range (m)
target_amplitude = 1;    % Simulated echo amplitude

% Calculate round-trip propagation delay
tau = 2 * target_range / c;

% Create received signal with enough time to include the echo
t_rx = 0:1/fs:(T + tau + 5e-6);

% Initialise received signal
rx = zeros(size(t_rx));

% Calculate the sample delay
delay_samples = round(tau * fs);

% Insert the transmitted chirp into the received signal
start_index = delay_samples + 1;
end_index = start_index + length(tx) - 1;

if end_index <= length(rx)
    rx(start_index:end_index) = target_amplitude * tx;
else
    error('Received signal is too short for the simulated echo.');
end

%% PLOT THE RECEIVED ECHO

figure;

plot(t_rx*1e6, real(rx), 'LineWidth', 1.2);

xlabel('Time (\mus)');
ylabel('Amplitude');
title('Simulated Radar Target Echo');
grid on;

saveas(gcf, fullfile(figuresFolder, ...
    'simulated_target_echo.png'));

%% MATCHED FILTER AND PULSE COMPRESSION

matched_filter = conj(fliplr(tx));

compressed_signal = conv(rx, matched_filter);

% Time axis for convolution output
t_compressed = (0:length(compressed_signal)-1)/fs;

% Find the strongest compressed peak
[peak_value, peak_index] = max(abs(compressed_signal));

% Estimate range from the peak time
estimated_delay = t_compressed(peak_index) - (T - 1/fs);
estimated_range = estimated_delay * c / 2;

%% PLOT THE PULSE-COMPRESSED SIGNAL

figure;

plot(t_compressed*1e6, abs(compressed_signal), ...
    'LineWidth', 1.2);

xlabel('Time (\mus)');
ylabel('Matched Filter Magnitude');
title('Radar Pulse Compression Output');
grid on;

saveas(gcf, fullfile(figuresFolder, ...
    'radar_pulse_compression.png'));

%% DISPLAY RESULTS

fprintf('\n--- STAGE 2 RESULTS ---\n');
fprintf('Simulated target range: %.2f metres\n', target_range);
fprintf('Round-trip delay: %.2f microseconds\n', tau*1e6);
fprintf('Matched-filter peak magnitude: %.4f\n', peak_value);
fprintf('Estimated target range: %.2f metres\n', estimated_range);

% Save results
stage2_results = table( ...
    target_range, tau, estimated_range, peak_value, ...
    'VariableNames', {'TrueRange_m', 'RoundTripDelay_s', ...
    'EstimatedRange_m', 'PeakMagnitude'});

writetable(stage2_results, ...
    fullfile(resultsFolder, 'pulse_compression_results.csv'));

disp('Stage 2 simulation completed.');
%% STAGE 3: TARGET RANGE ESTIMATION

% Calculate the range axis for the pulse-compressed signal
range_axis = t_compressed * c / 2;

% Plot the pulse-compressed signal against target range
figure;

plot(range_axis, abs(compressed_signal), ...
    'LineWidth', 1.5);

xlabel('Range (metres)');
ylabel('Matched Filter Magnitude');
title('Radar Target Range Profile');
grid on;

% Mark the strongest detected peak
hold on;

plot(estimated_range, peak_value, 'ro', ...
    'MarkerSize', 8, 'LineWidth', 1.5);

legend('Range Profile', 'Detected Peak', ...
    'Location', 'best');

hold off;

% Save the figure
saveas(gcf, fullfile(figuresFolder, ...
    'radar_target_range_profile.png'));

% Display the estimated range
fprintf('\n--- STAGE 3 RESULTS ---\n');
fprintf('Estimated target range: %.2f metres\n', ...
    estimated_range);

disp('Target range profile generated successfully.');
%% STAGE 4: DOPPLER PROCESSING

% Radar parameters
c = 3e8;                  % Speed of light (m/s)
fc = 10e9;                % Carrier frequency: 10 GHz
target_velocity = 30;     % Target velocity (m/s)

% Calculate Doppler frequency
fd = 2 * target_velocity * fc / c;

% Simulate a sequence of received pulses
num_pulses = 64;
pulse_repetition_interval = 1e-3;

slow_time = (0:num_pulses-1) ...
    * pulse_repetition_interval;

% Simulate the Doppler phase change across pulses
received_pulses = exp(1j * 2 * pi * fd * slow_time);

% Perform Doppler processing using the FFT
doppler_spectrum = fftshift( ...
    fft(received_pulses, 1024));

% Create the Doppler frequency axis
doppler_frequency = (-512:511) ...
    / (1024 * pulse_repetition_interval);

% Find the strongest Doppler peak
[~, doppler_peak_index] = max(abs(doppler_spectrum));

estimated_doppler_frequency = ...
    doppler_frequency(doppler_peak_index);

% Estimate radial velocity
estimated_velocity = ...
    estimated_doppler_frequency * c / (2 * fc);

%% PLOT THE DOPPLER SPECTRUM

figure;

plot(doppler_frequency, ...
    abs(doppler_spectrum), 'LineWidth', 1.5);

xlabel('Doppler Frequency (Hz)');
ylabel('Magnitude');
title('Radar Doppler Spectrum');
grid on;

hold on;

plot(estimated_doppler_frequency, ...
    abs(doppler_spectrum(doppler_peak_index)), ...
    'ro', 'MarkerSize', 8, 'LineWidth', 1.5);

legend('Doppler Spectrum', 'Detected Peak', ...
    'Location', 'best');

hold off;

saveas(gcf, fullfile(figuresFolder, ...
    'radar_doppler_spectrum.png'));

%% DISPLAY AND SAVE RESULTS

fprintf('\n--- STAGE 4 RESULTS ---\n');
fprintf('Carrier frequency: %.2f GHz\n', fc/1e9);
fprintf('True target velocity: %.2f m/s\n', target_velocity);
fprintf('True Doppler frequency: %.2f Hz\n', fd);
fprintf('Estimated Doppler frequency: %.2f Hz\n', ...
    estimated_doppler_frequency);
fprintf('Estimated target velocity: %.2f m/s\n', ...
    estimated_velocity);

stage4_results = table( ...
    target_velocity, fd, estimated_doppler_frequency, ...
    estimated_velocity, ...
    'VariableNames', {'TrueVelocity_mps', ...
    'TrueDoppler_Hz', 'EstimatedDoppler_Hz', ...
    'EstimatedVelocity_mps'});

writetable(stage4_results, ...
    fullfile(resultsFolder, 'doppler_results.csv'));

disp('Doppler processing completed successfully.');
%% STAGE 5: RANGE-DOPPLER MAP

% Radar parameters
c = 3e8;
fc = 10e9;
B = 20e6;
T = 20e-6;
fs = 100e6;

% Simulation parameters
num_pulses = 64;
target_range = 1500;
target_velocity = 30;

% Calculate target delay and Doppler frequency
tau = 2 * target_range / c;
fd = 2 * target_velocity * fc / c;

% Generate transmitted LFM chirp
K = B / T;
t = 0:1/fs:T-1/fs;
tx = exp(1j*pi*K*t.^2);

% Generate simulated received pulses
rx_matrix = zeros(num_pulses, length(tx));

for p = 1:num_pulses

    % Apply target delay
    delayed_signal = zeros(size(tx));
    delay_samples = round(tau * fs);

    if delay_samples < length(tx)
        delayed_signal(delay_samples+1:end) = ...
            tx(1:end-delay_samples);
    end

    % Apply Doppler phase across pulses
    slow_time = (p-1)*1e-3;
    rx_matrix(p,:) = delayed_signal .* ...
        exp(1j*2*pi*fd*slow_time);

end

%% RANGE PROCESSING

matched_filter = conj(fliplr(tx));
range_compressed = zeros(size(rx_matrix));

for p = 1:num_pulses
    temp = conv(rx_matrix(p,:), matched_filter);
    range_compressed(p,:) = ...
        temp(length(tx):2*length(tx)-1);
end

%% DOPPLER PROCESSING

nfft_doppler = 256;

range_doppler_map = fftshift( ...
    fft(range_compressed, nfft_doppler, 1), 1);

%% CREATE AXES

range_axis = (0:length(tx)-1)/fs*c/2;

doppler_frequency_axis = ...
    (-nfft_doppler/2:nfft_doppler/2-1) ...
    /(nfft_doppler*1e-3);

velocity_axis = doppler_frequency_axis*c/(2*fc);

%% PLOT RANGE-DOPPLER MAP

figure;

imagesc(range_axis, velocity_axis, ...
    20*log10(abs(range_doppler_map) + eps));

axis xy;
xlabel('Range (m)');
ylabel('Radial Velocity (m/s)');
title('Simulated Radar Range-Doppler Map');
colorbar;
grid on;

saveas(gcf, fullfile(figuresFolder, ...
    'radar_range_doppler_map.png'));

%% DISPLAY RESULTS

fprintf('\n--- STAGE 5 RESULTS ---\n');
fprintf('Simulated target range: %.2f m\n', target_range);
fprintf('Simulated target velocity: %.2f m/s\n', ...
    target_velocity);

disp('Range-Doppler map generated successfully.');
%% STAGE 6: MULTIPLE TARGET SIMULATION

clearvars -except figuresFolder resultsFolder;

% Radar parameters
c = 3e8;
fc = 10e9;
B = 20e6;
T = 20e-6;
fs = 100e6;

% Pulse processing parameters
num_pulses = 64;
PRI = 1e-3;
nfft_doppler = 256;

% Generate transmitted LFM chirp
K = B/T;
t = 0:1/fs:T-1/fs;
tx = exp(1j*pi*K*t.^2);
num_samples = length(tx);

% Define two simulated targets
target_ranges = [1500, 2400];       % metres
target_velocities = [30, -20];      % m/s
target_amplitudes = [1, 0.7];

% Initialise received signal matrix
rx_matrix = complex(zeros(num_pulses, num_samples));

% Simulate received pulses
for p = 1:num_pulses

    slow_time = (p-1)*PRI;

    for k = 1:length(target_ranges)

        % Calculate target delay and Doppler frequency
        tau = 2*target_ranges(k)/c;
        delay_samples = round(tau*fs);
        fd = 2*target_velocities(k)*fc/c;

        % Generate delayed target echo
        delayed_echo = complex(zeros(1, num_samples));

        if delay_samples < num_samples
            delayed_echo(delay_samples+1:end) = ...
                tx(1:end-delay_samples);
        end

        % Add Doppler phase
        delayed_echo = delayed_echo .* ...
            exp(1j*2*pi*fd*slow_time);

        % Add target echo to received signal
        rx_matrix(p,:) = rx_matrix(p,:) + ...
            target_amplitudes(k)*delayed_echo;

    end
end

%% RANGE COMPRESSION

matched_filter = conj(fliplr(tx));

range_compressed = complex( ...
    zeros(num_pulses, num_samples));

for p = 1:num_pulses
    temp = conv(rx_matrix(p,:), matched_filter);

    range_compressed(p,:) = ...
        temp(num_samples:2*num_samples-1);
end

%% DOPPLER PROCESSING

range_doppler_map = fftshift( ...
    fft(range_compressed, nfft_doppler, 1), 1);

% Axes
range_axis = (0:num_samples-1)/fs*c/2;

doppler_frequency_axis = ...
    (-nfft_doppler/2:nfft_doppler/2-1)/(nfft_doppler*PRI);

velocity_axis = doppler_frequency_axis*c/(2*fc);

% Convert magnitude to decibels
rd_magnitude_db = 20*log10( ...
    abs(range_doppler_map)/max(abs(range_doppler_map(:))) + eps);

%% PLOT MULTIPLE-TARGET RANGE-DOPPLER MAP

figure;

imagesc(range_axis, velocity_axis, rd_magnitude_db);
axis xy;

xlabel('Range (m)');
ylabel('Radial Velocity (m/s)');
title('Range-Doppler Map: Two Simulated Targets');

colorbar;
clim([-50 0]);

hold on;

plot(target_ranges, target_velocities, 'wx', ...
    'MarkerSize', 10, 'LineWidth', 2);

legend('Simulated Target Positions', ...
    'Location', 'best');

hold off;

saveas(gcf, fullfile(figuresFolder, ...
    'multiple_target_range_doppler_map.png'));

%% SAVE TARGET PARAMETERS

target_results = table( ...
    target_ranges(:), ...
    target_velocities(:), ...
    target_amplitudes(:), ...
    'VariableNames', ...
    {'TargetRange_m', 'TargetVelocity_mps', ...
     'TargetAmplitude'});

writetable(target_results, ...
    fullfile(resultsFolder, 'multiple_target_parameters.csv'));

fprintf('\n--- STAGE 6 RESULTS ---\n');

for k = 1:length(target_ranges)
    fprintf('Target %d: Range = %.0f m, Velocity = %.0f m/s\n', ...
        k, target_ranges(k), target_velocities(k));
end

disp('Multiple-target simulation completed.');
%% STAGE 7: CONCEPTUAL RADAR SYSTEM ARCHITECTURE

figure('Color', 'w', 'Position', [100 100 1100 600]);

axis([0 12 0 7]);
axis off;
hold on;

% Component positions: [x, y, width, height]
components = {
    'Waveform Generator',       0.5, 4.8, 2.0, 1.0;
    'Transmitter',              3.0, 4.8, 1.6, 1.0;
    'Transmit Antenna',         5.1, 4.8, 1.8, 1.0;
    'Target / Environment',     7.6, 4.8, 2.0, 1.0;
    'Receive Antenna',          7.6, 2.6, 2.0, 1.0;
    'Receiver',                 5.1, 2.6, 1.8, 1.0;
    'Signal Processing',        2.7, 2.6, 2.0, 1.0;
    'Range / Doppler Output',   0.3, 2.6, 2.0, 1.0
    };

% Draw component boxes
for k = 1:size(components, 1)

    label = components{k, 1};
    x = components{k, 2};
    y = components{k, 3};
    w = components{k, 4};
    h = components{k, 5};

    rectangle('Position', [x y w h], ...
        'Curvature', 0.08, ...
        'LineWidth', 1.5);

    text(x+w/2, y+h/2, label, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 9, ...
        'Interpreter', 'none');
end

% Transmit signal path
annotation('arrow', [0.205 0.285], [0.72 0.72]);
annotation('arrow', [0.405 0.455], [0.72 0.72]);
annotation('arrow', [0.575 0.635], [0.72 0.72]);

% Receive signal path
annotation('arrow', [0.795 0.795], [0.68 0.49]);
annotation('arrow', [0.635 0.575], [0.42 0.42]);
annotation('arrow', [0.425 0.395], [0.42 0.42]);
annotation('arrow', [0.225 0.195], [0.42 0.42]);

% Title and explanation
text(6, 6.4, 'Conceptual Radar System Architecture', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 16, ...
    'FontWeight', 'bold');

text(6, 1.2, ...
    'Conceptual block diagram for a simulated radar system. Not a hardware implementation.', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 10, ...
    'Interpreter', 'none');

hold off;

% Save the diagram
saveas(gcf, fullfile(pwd, ...
    'documentation', 'radar_system_architecture.png'));

disp('Conceptual radar architecture diagram created.');
%% STAGE 8: GENERATE PROJECT REPORT

reportFile = fullfile(pwd, 'documentation', ...
    'radar_waveform_range_doppler_report.txt');

fid = fopen(reportFile, 'w');

if fid == -1
    error('Could not create report. Check the documentation folder.');
end

fprintf(fid, 'RADAR WAVEFORM AND RANGE-DOPPLER SIMULATION\n');
fprintf(fid, '===========================================\n\n');

fprintf(fid, '1. PROJECT OVERVIEW\n');
fprintf(fid, ['This project uses MATLAB to explore linear frequency-modulated ' ...
    'radar waveforms, matched filtering, range estimation, Doppler processing, ' ...
    'and a conceptual range-Doppler map.\n\n']);

fprintf(fid, '2. OBJECTIVES\n');
fprintf(fid, '- Generate a simulated linear frequency-modulated chirp.\n');
fprintf(fid, '- Simulate target echoes and matched-filter pulse compression.\n');
fprintf(fid, '- Explore range estimation and Doppler frequency analysis.\n');
fprintf(fid, '- Visualise a simplified range-Doppler response.\n');
fprintf(fid, '- Document a conceptual radar system architecture.\n\n');

fprintf(fid, '3. WAVEFORM PARAMETERS\n');
fprintf(fid, 'Bandwidth: 20 MHz\n');
fprintf(fid, 'Pulse duration: 20 microseconds\n');
fprintf(fid, 'Sampling frequency: 100 MHz\n');
fprintf(fid, 'Carrier frequency for Doppler examples: 10 GHz\n\n');

fprintf(fid, '4. KEY ENGINEERING CONCEPTS\n');
fprintf(fid, ['Range resolution is related to signal bandwidth. ' ...
    'For an ideal waveform, the approximate range resolution is c/(2B).\n']);
fprintf(fid, ['Round-trip propagation delay can be converted to range ' ...
    'using R = c*tau/2.\n']);
fprintf(fid, ['For a monostatic radar and a target moving radially, ' ...
    'Doppler frequency is related to velocity by fd = 2*v*fc/c, ' ...
    'subject to the chosen sign convention.\n\n']);

fprintf(fid, '5. SIMULATION OUTPUTS\n');
fprintf(fid, '- LFM chirp waveform and frequency sweep.\n');
fprintf(fid, '- Simulated target echo and pulse-compression output.\n');
fprintf(fid, '- Target range profile.\n');
fprintf(fid, '- Doppler spectrum.\n');
fprintf(fid, '- Simplified range-Doppler visualisations.\n');
fprintf(fid, '- Conceptual radar system architecture diagram.\n\n');

fprintf(fid, '6. LIMITATIONS\n');
fprintf(fid, ['This project is a simulation, not a physical radar system. ' ...
    'It does not demonstrate real antenna hardware, RF circuitry, ' ...
    'FPGA implementation, or measurements from a real radar.\n']);
fprintf(fid, ['The range-Doppler implementation uses simplified echo and ' ...
    'processing assumptions. Its target estimates must be validated ' ...
    'before quantitative performance claims are made.\n\n']);

fprintf(fid, '7. CONCLUSION\n');
fprintf(fid, ['The project demonstrates an initial MATLAB-based exploration ' ...
    'of radar waveform generation and signal processing. Further work ' ...
    'should validate range and velocity estimates, introduce noise and ' ...
    'clutter models, and assess detection performance.\n']);

fclose(fid);

fprintf('\nProject report saved to:\n%s\n', reportFile);