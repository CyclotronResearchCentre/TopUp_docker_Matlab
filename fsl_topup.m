%% TopUp
% This function calls topup from inside the docker image.
% Parameters
%   imain (string) : The full path to the image.
%   datain (string) : The full path to the acquisition parameters file.
%   config (string) : The full path to the config file.
%   b_out (string) : The basename of the output files.
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (string) : The stdout of the call.
function [status, cmd_out] = fsl_topup(imain, datain, config, b_out)

in_files = char(imain, datain, config);
%     in_files = [imain, datain, config];
[~, imain_name, imain_ext] = fileparts(imain);
[~, datain_name, datain_ext] = fileparts(datain);
[~, config_name, config_ext] = fileparts(config);
cmd = sprintf('topup --imain=%s --datain=%s --config=%s --out=%s --verbose', ...
    [imain_name, imain_ext], ...
    [datain_name, datain_ext], ...
    [config_name, config_ext], ...
    b_out);

% create regexp filter for output files
filt_out = ['^', b_out,'.*'];
[status, cmd_out] = fsl(cmd, in_files, filt_out);
%     [status, cmd_out] = fsl(cmd, in_files, strcat(out, '*'));
end
