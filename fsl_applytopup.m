%% Apply TopUp
% This function calls applytopup from inside the docker image.
% Parameters
%   imain (string) : The path to the image.
%   datain (string) : The path to the acquisition parameters file.
%   topup (string) : The basename of the topup results.
%   method (string) : The method to use (e.g. 'jac').
%   interp (string) : The interpolation method (e.g. 'spline').
%   out (string) : The basename of the output files.
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (string) : The stdout of the call.
function [status, cmd_out] = fsl_applytopup(imain, inindex, datain, topup, method, interp, out)
    in_files = [imain, datain];
    topup_res = dir(strcat(topup, '*'));
    for i = 1:length(topup_res)
        in_files = [in_files, fullfile(topup_res(i).folder, topup_res(i).name)];
    end
    [filepath, imain_name, ext] = fileparts(imain);
    [filepath, datain_name, datain_ext] = fileparts(datain);
    [filepath, topup_name, ext] = fileparts(topup);
    cmd = join(['applytopup', ...
                strcat('--imain=', imain_name), ...
                strcat('--inindex=', inindex), ...
                strcat('--datain=', datain_name, datain_ext), ...
                strcat('--topup=', topup_name), ...
                strcat('--method=', method), ...
                strcat('--interp=', interp), ...
                strcat('--out=', out), ...
                '--verbose']);
    [status, cmd_out] = fsl(cmd, in_files, strcat(out, '*'));
end
