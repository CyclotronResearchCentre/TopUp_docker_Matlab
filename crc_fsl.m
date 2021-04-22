function [status, cmd_out] = crc_fsl(cmd, twd, onm)
%% Define FSL call function
% 
% Call FSL TopUp function from inside a docker image.
% 
% INPUT
% - cmd : The command to run inside the docker.
% - twd : Path to the "working" folder where all the data and parameter 
%           files to be used are stored.
% - onm : [optional] Operation name, for the shell script filename
% 
% OUTPUT
% - status (int) : The exit code of the call (0/1 for OK/problem).
% - cmd_out (char) : The stdout of the call.
% 
% Depending on a default "fl_save_shscr" flag, the shell script executed is
% saved in a filename formated as crc_topup_[onm].sh
% 
% Notes
%   This function requires the 'DOCKER_EXEC' and 'FSL_IMG' environment
%   variables to be defined.
%   This function works in a specific directory and copies all the
%   required input files into that directory.
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Deal with input & default
if nargin<3, onm=''; end
% Flag to save, or not, the shell script command
fl_save_shscr = crc_topup_get_defaults('fl_save_shscr');

%% Prepare the FSL-docker command
% docker_exec = getenv('DOCKER_EXEC');
docker_exec = 'docker'; % hardcoded for Docker
fsl_img = crc_topup_get_defaults('fsl_img');
docker_cmd = sprintf('%s run --rm -v %s:/home/fsl %s', ...
    docker_exec, twd, fsl_img);

%% Send the 'cmd' to the Docker via the 'docker_cmd'
full_cmd = sprintf('%s %s', docker_cmd, cmd);
if fl_save_shscr
    % save TopUp call
    cc = 0;
    fn_sh = create_fn_sh(twd,cc,onm); 
    while exist(fn_sh,'file')
        % If file already exist, add an index as a suffix
        cc = cc+1;
        fn_sh = create_fn_sh(twd,cc,onm);
    end
    % save in new shell file, discard existing contents 
    fid = fopen(fn_sh,'w');
    fprintf(fid,'%s',full_cmd);
    fclose(fid) ;
end
[status, cmd_out] = system( full_cmd );

if status % something went wrong
    fprintf('\nPROBLEM: this command did not work: \n%s\n',full_cmd);
    fprintf('\nOutput message states: \n%s\n',cmd_out);
end

end

%% SUBFUNCTION
function fn_sh = create_fn_sh(twd,cc,onm)
% Create shell script filename, with/without the operation name & index
fn_sh = 'crc_topup';
if ~isempty(onm)
    fn_sh = sprintf('%s_%s',fn_sh,onm);
end
if cc>0
    fn_sh = sprintf('%s_%2d',fn_sh,cc);
end
fn_sh = fullfile( twd, [fn_sh , '.sh']);

end


