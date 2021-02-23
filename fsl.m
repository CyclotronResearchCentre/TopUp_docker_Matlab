%% Define FSL function
% Call FSL from inside a docker image.
% Parameters
%   cmd (string) : The command to run inside the docker.
%   in_files (list[string]) : A list of the input files required by the
%       command.
%   out_patterns (list[string]) : A list of patterns matching all the
%       output files of the command that must be saved.
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (string) : The stdout of the call.
% Notes
%   This function requires the 'DOCKER_EXEC' and 'FSL_IMG' environment
%   variables to be defined.
%   This function works in a temporary directory and copies all the
%   required input files into that directory.

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
%     docker_cmd = join([docker_exec, 'run', '--rm', '-v', strcat(twd, ':', '/home/fsl'), fsl_img]);

    [status, cmd_out] = system( sprintf('%s %s', docker_cmd, cmd) );
    % Removing the '-echo' which was generating an error
    
%     [status, cmd_out] = system(join([docker_cmd, cmd]), '-echo');

% Copy all the output files to the initial directory
    for ii = 1 :size(out_patterns,1)
        movefile(out_patterns(ii), cwd);
    end
    % Clean temporary directory and go back to initial directory
    delete('*');
    cd(cwd);
    rmdir(twd);
    if ~exist(twd,'dir')
        fprintf('\nTemporary folder removed');
    end
%     isfolder(twd)
end
