%% Define FSL function
% Call FSL from inside a docker image.
% Parameters
%   cmd : The command to run inside the docker.
%   twd : Path to the "working" folder where all the data and parameter 
%           files to be used are stored.
% 
% Returns
%   status (int) : The exit code of the call (0/1 for OK/problem).
%   cmd_out (char) : The stdout of the call.
% 
% Notes
%   This function requires the 'DOCKER_EXEC' and 'FSL_IMG' environment
%   variables to be defined.
%   This function works in a temporary directory and copies all the
%   required input files into that directory.
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

function [status, cmd_out] = crc_fsl(cmd, twd)

% Run the FSL command
docker_exec = getenv('DOCKER_EXEC');
fsl_img = getenv('FSL_IMG');
docker_cmd = sprintf('%s run --rm -v %s:/home/fsl %s', ...
    docker_exec, twd, fsl_img);

% Send the 'cmd' to the Docker via the 'docker_cmd'
full_cmd = sprintf('%s %s', docker_cmd, cmd);
[status, cmd_out] = system( full_cmd );

if status % something went wrong
    fprintf('\nPROBLEM: this command did not work: \n%s\n',full_cmd)
    fprintf('\nOutput message states: \n%s\n',cmd_out);
end

end


