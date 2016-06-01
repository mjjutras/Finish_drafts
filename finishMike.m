% FINISHSAV  Save workspace variables
%   Change the name of this file to FINISH.M
%   and put it anywhere on your MATLAB path.
%   When you quit MATLAB this file will be executed.
%   This script saves all the variables in the
%   work space to a MAT-file.
%
%   Copyright 1984-2000 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2000/06/01 16:19:26 $
%
%   Written by Seth Konig. All code runs automatically
%   1st section backs up every .m code to the network
%   2nd section commits code changes to git and pushes to github
%
%   This version revised 2016-05-25 by Mike Jutras for use on RBU-MikeJ2

homedir = 'C:\Users\michael.jutras\Documents\MATLAB\'; % Matlab's home dir where all folders are stored
cd(homedir);
netdir = 'R:\Buffalo Lab\Mike\MATLAB\'; % location to store file copies
% disp('Saving workspace data');
% save([homedir 'LastWorkSpace']) %save the last things on the workspace just in case...optional

%%
%%---Backup Anything that has been changed in the last ## days---%
datebuffer = 7; %files that have changed in the last # many days to backup

% any subdirectories within the main homedir folder that begin with any of
% the following strings will be removed from the list of dirs to copy
% especially useful for 'fieldtrip'
dir_not_to_copy = {'fieldtrip' 'asv' 'Blackrock' 'CSD' 'CircStat2010b' ...
    'export_fig'};

% get list of all subdirectories within homedir
p = genpath(homedir);
enddirnam = find(p==';');
dir_to_copy = cell(length(enddirnam),1);
for k = 1:length(enddirnam)
    if k==1
        dir_to_copy{k} = p(length(homedir)+1:enddirnam(k)-1);
    else
        dir_to_copy{k} = p(enddirnam(k-1)+length(homedir)+1:enddirnam(k)-1);
    end
end

% remove dir_not_to_copy folders from dir_to_copy
for k = 1:length(dir_not_to_copy)
    dir_to_copy = dir_to_copy(~strncmp(dir_not_to_copy{k},dir_to_copy,length(dir_not_to_copy{k})));
end

% remove .git folders
ind = strfind(dir_to_copy,'.git');
dir_to_copy = dir_to_copy(cellfun('isempty',ind));

disp('Saving Matlab files to Network...');
tic
today = datenum(clock);
filecopylist = {};
c = 1;
for d = 1:length(dir_to_copy)
    if ~isdir(fullfile(netdir,dir_to_copy{d})) % if directory does not exist on network
        mkdir(fullfile(netdir,dir_to_copy{d}))
    end
    files = dir(fullfile(homedir,dir_to_copy{d},'\*.m')); % only copies .m files
    for f = 1:length(files)
        if (today - files(f).datenum) < datebuffer
            copyfile(fullfile(homedir,dir_to_copy{d},files(f).name),...
                fullfile(netdir,dir_to_copy{d},files(f).name),'f')
            disp(['Copying ' fullfile(homedir,dir_to_copy{d},files(f).name)])
            filecopylist{c,1} = fullfile(homedir,dir_to_copy{d},files(f).name);
            c = c+1;
        end
    end
end
disp('Files successfully backed up to the network!')

%%---Commit changes to git repositories---%
% must have respositories named the same as your directories
disp('Committing Files to Git Repositories')
repolist = {};
c = 1;
for d = 1:length(filecopylist)
    
    [pathstr, filename, ext] = fileparts(filecopylist{d});
    if ~isempty(find(pathstr(length(homedir)+1:end)==filesep,1))
        reponame = pathstr(length(homedir)+1:find(pathstr(length(homedir)+1:end)==filesep,1,'first')+length(homedir)-1);
    else
        reponame = pathstr(length(homedir)+1:end);
    end
    
    if isempty(ismember(repolist,reponame))
        repolist{c} = reponame;
        c = c+1;
    end
    
end

for d = 1:length(repolist)
    
    reponame = repolist{d};

    [~,result] = system(['git ls-remote ' reponame]);
    if ~isempty(strfind(result,'fatal')) % init repository if it does not already exist
        system(['git init ' reponame]);
    end
    
    cd(fullfile(homedir,reponame))
    for f = 1:length(filecopylist)
        if filecopylist{f}
                        system(['git add ' files(f).name]);
                        disp(['Adding ' [homedir dd(d).name '\' files(f).name] ' to repository'])
                    end
                end
                %commit changes to git repository for all files in folder
                system(['git commit -m autocommit_' date]); % prompt to add alternative message to commit?
                %push changes to github
                system(['git push -u ' reponame ' master'])
            end
        end
    end
    cd(homedir);
end
disp('Code changes sucessfully tracked by Git')
toc
