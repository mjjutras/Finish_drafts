% FINISHSAV  Save workspace variables
%   Change the name of this file to FINISH.M
%   and put it anywhere on your MATLAB path.
%   When you quit MATLAB this file will be executed.
%
%   Copyright 1984-2000 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2000/06/01 16:19:26 $
%
%   Written by Seth Konig. All code runs automatically
%   1st section backs up every .m code to the network
%   2nd section commits code changes to git and pushes to github

homedir = 'C:\Users\seth.koenig\Documents\MATLAB\'; %Matlab's home dir where all folders are stored
cd(homedir);
network = '\\research.wanprc.org\Research\Buffalo Lab\Seth\'; %location to store file copies
disp('Saving workspace data');
save([homedir 'LastWorkSpace']) %save the last things on the workspace just in case...optional
%%
%%---Backup Anything that has been changed in the last ## days---%
datebuffer=7; %files that have changed in the last # many days to backup

dir_not_to_copy = {'Apps','classificator_1.5','fieldtrip-20100808','generic',...
    'IBS522R Fake Data','TL_recording_data','Face Cells','VPC ASL'};
disp('Saving Matlab files to Network...');
tic
dd = dir(homedir);
today = datenum(clock);
for d = 1:length(dd);
    if dd(d).isdir;
        if ~strcmpi(dd(d).name(1),'.') %not matlab folders
            if ~any(strcmpi(dir_not_to_copy,dd(d).name)) %don't want to save these to network either
                if ~isdir([network dd(d).name]) %if directory does not exist on network
                    mkdir([network dd(d).name])
                end
                files = dir([homedir dd(d).name,'\*.m']); %only copies .m files
                for f = 1:length(files);
                    if (today - files(f).datenum) < datebuffer
                        copyfile([homedir dd(d).name '\' files(f).name],...
                            [network dd(d).name '\' files(f).name],'f')
                        disp(['Copying ' [homedir dd(d).name '\' files(f).name]])
                    end
                end
            end
        end
    end
end
disp('Files successfully backedup to the network!')

%%---Commit changes to git repositories---%
githttps = 'https://github.com/skoenig3/'; %url for your respositories
% must have respositories named the same as your directories
disp('Committing Files to Git Repositories and Pushing to GitHub')
for d = 1:length(dd);
    if dd(d).isdir;
        if ~strcmpi(dd(d).name(1),'.') %not matlab folders
            if ~any(strcmpi(dir_not_to_copy,dd(d).name)) %don't want to save these to network either
                
                %spaces don't work with git/cmd unless you add " " around directory with spaces
                %github replaces spaces with -
                %assumes no double space!!!!
                spaces = find(isspace(dd(d).name));
                if isempty(spaces);
                    new_dir_name2 = dd(d).name;
                    new_dir_name = dd(d).name;
                else
                    new_dir_name = ['"' dd(d).name '"'];
                    new_dir_name2 = []; %for Github location
                    for s = 1:length(spaces)+1
                        if s == 1
                            new_dir_name2 = [new_dir_name2 dd(d).name(1:spaces-1) '-'];
                        elseif s == length(spaces)+1
                            
                            new_dir_name2 = [new_dir_name2 dd(d).name(spaces(end)+1:end)];
                        else
                            new_dir_name2 = [new_dir_name2 dd(d).name(spaces(s-1)+1:spaces(s)-1)  '-'];
                        end
                    end
                end
                
                [~,result] = system(['git ls-remote ' new_dir_name]);
                if ~isempty(strfind(result,'fatal')) % if repository does not exist so lets make it
                    system(['git init ' new_dir_name]);
                    system(['git remote add ' new_dir_name2 ' ' githttps new_dir_name2 '.git']) 
                    %makes connection between git repository and github
                end
                
                cd([homedir dd(d).name])
                files = dir([homedir dd(d).name,'\*.m']);
                for f = 1:length(files);
                    if (today - files(f).datenum) < datebuffer
                        system(['git add ' files(f).name]);
                        disp(['Adding ' [homedir dd(d).name '\' files(f).name] ' to repository'])
                    end
                end
                %commit changes to git repository for all files in folder
                system(['git commit -m autocommit_' date]);
                %push changes to github
                system(['git push -u ' new_dir_name2 ' master'])
            end
        end
    end
    cd(homedir);
end
disp('Code changes sucessfully tracked by Git')
toc