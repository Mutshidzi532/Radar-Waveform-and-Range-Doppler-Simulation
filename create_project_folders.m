%%\ CREATE PROJECT FOLDERS
clear;
clc;
folders = {'figures', 'results', 'documentation'};
for k = 1:length(folders) %[output:group:856f3b5c]
    if ~exist(folders{k}, 'dir')
        mkdir(folders{k});
        fprintf('Created folder: %s\n', folders{k});
    else
        fprintf('Folder already exists: %s\n', folders{k}); %[output:8094b7c4]
    end
end %[output:group:856f3b5c]
disp('All project folders are ready.'); %[output:6659e7e5]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:8094b7c4]
%   data: {"dataType":"text","outputData":{"text":"Folder already exists: figures\nFolder already exists: results\nFolder already exists: documentation\n","truncated":false}}
%---
%[output:6659e7e5]
%   data: {"dataType":"text","outputData":{"text":"All project folders are ready.\n","truncated":false}}
%---
