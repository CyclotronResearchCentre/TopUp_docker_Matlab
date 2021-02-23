%% Apply TopUp
% This function calls applytopup from inside the docker image.
% Parameters
%   imain (string) : The path to the image.
%   datain (string) : The path to the acquisition parameters file.
%   topup (string) : The basename of the topup results.
%   method (string) : The method to use (e.g. 'jac').
%   interp (string) : The interpolation method (e.g. 'spline').
%   b_out (string) : The basename of the output files.
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (string) : The stdout of the call.

function [status, cmd_out] = fsl_applytopup(imain, inindex, datain, topup, method, interp, b_out)

% List of all necessary file -> to be moved into temp folder
in_files = char(imain, datain);
topup_res = dir(strcat(topup, '*'));

for i = 1:length(topup_res)
    in_files = char(in_files, topup_res(i).name);
end

[~, imain_name, imain_ext] = fileparts(imain);
[~, datain_name, datain_ext] = fileparts(datain);
[~, topup_name, ext] = fileparts(topup);
cmd = sprintf(['applytopup --imain=%s --inindex=%s --datain=%s ', ...
               '--topup=%s --method=%s --interp=%s --out=%s --verbose'], ...
    imain_name, inindex, [datain_name, datain_ext], topup_name, ...
    method, interp, b_out);

% create regexp filter for output files
filt_out = ['^', b_out,'.*'];

% call to fsl-topup
[status, cmd_out] = fsl(cmd, in_files, filt_out);

end
