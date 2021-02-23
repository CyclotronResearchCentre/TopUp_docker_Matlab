%% TopUp
% This function calls topup from inside the docker image.
% Parameters
%   imain (string) : The path to the image.
%   datain (string) : The path to the acquisition parameters file.
%   config (string) : The path to the config file.
%   out (string) : The basename of the output files.
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (string) : The stdout of the call.
function [status, cmd_out] = fsl_topup(imain, datain, config, out)
    in_files = [imain, datain, config];
    [filepath, imain_name, ext] = fileparts(imain);
    [filepath, datain_name, datain_ext] = fileparts(datain);
    [filepath, config_name, config_ext] = fileparts(config);
    cmd = join(["topup", ...
                strcat("--imain=", imain_name), ...
                strcat("--datain=", datain_name, datain_ext), ...
                strcat("--config=", config_name, config_ext), ...
                strcat("--out=", out), ...
                "--verbose"]);
    [status, cmd_out] = fsl(cmd, in_files, strcat(out, "*"));
end
