%% Define FSL function
% Call FSL from inside a docker image.
% Parameters
%   cmd (char) : The command to run inside the docker.
%   in_files (char array) : A list of the input files required by the
%       command.
%   out_patterns (char array) : A list of patterns matching all the
%       output files of the command that must be saved.
% Returns
%   status (int) : The exit code of the call (0/1 for OK/problem).
%   cmd_out (char) : The stdout of the call.
% Notes
%   This function requires the 'DOCKER_EXEC' and 'FSL_IMG' environment
%   variables to be defined.
%   This function works in a temporary directory and copies all the
%   required input files into that directory.
%__________________________________________________________________________
% Copyright (C) 2020 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2020.
% GIGA Institute, University of Liege, Belgium

function [status, cmd_out] = fsl(cmd, in_files, out_patterns)

% Create temporary directory
cwd = pwd;
twd = tempname(tempdir);
err = mkdir(twd);
if err ~= 1
    status = 0;
    cmd_out = 'Unable to create temporary directory';
    return
end
% Copy all the input files
for ii = 1 : size(in_files,1)
    copyfile(in_files(ii,:), twd);
end
% Move to temporary directory
cd(twd);
% Run the FSL command
docker_exec = getenv('DOCKER_EXEC');
fsl_img = getenv('FSL_IMG');
docker_cmd = sprintf('%s run --rm -v %s:/home/fsl %s', ...
    docker_exec, twd, fsl_img);

% Removing the '-echo' which was generating an error
full_cmd = sprintf('%s %s', docker_cmd, cmd);
[status, cmd_out] = system( full_cmd );

if status % something went wrong
    fprintf('\nPROBLEM: this command did not work: \n%s\n',full_cmd)
    fprintf('\nOutput message states: \n%s\n',cmd_out);
end
% Copy all the output files to the initial directory, based on regexp
fn_list = ls; % list of current files
fn_list(1:2,:) = []; % removing current and up folder.
for ii = 1:size(out_patterns,1)
    fn_mv = file_filter(fn_list,out_patterns(ii,:));
    for jj = 1:size(fn_mv,1)
        movefile(deblank(fn_mv(jj,:)), cwd);
    end
end
% Clean temporary directory and go back to initial directory
delete('*');
cd(cwd);
rmdir(twd);
if ~exist(twd,'dir')
    fprintf('\nTemporary folder removed\n');
end

end

function fn_mv = file_filter(fn_list,fn_regexp)
% Find subset of filenames based on list and reg-expression
if ~iscell(fn_list)
    fn_list = cellstr(fn_list);
end
% get list of matching filenames
ll_list = ~cellfun('isempty',regexp(fn_list,fn_regexp));
fn_mv = char(fn_list(ll_list));

end

