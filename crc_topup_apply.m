%% Apply TopUp
% This function calls applytopup from inside the docker image.
% Parameters
%   imain (char)  : path to the image to correct.
%   inindex (int) : relation between the list of files given by --imain and
%                   the acquisition parameters in my_acq_param.txt
%   datain (char) : path to the acquisition parameters file.
%   topup (char)  : prefix of the topup results.
%   method (char) : method to use (e.g. 'jac').
%   interp (char) : interpolation method (e.g. 'spline').
%   b_out (char)  : prefix of the output files.
%   pth_tuc       : path to topup spline coeficients
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (char) : The stdout of the call.
% 
% References for the Apply TopUp tool:
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/ApplyTopupUsersGuide
% 
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium


function [status, cmd_out] = crc_topup_apply(imain, inindex, datain, topup, method, interp, b_out,pth_tuc)

% Checking if parameters are in the data folder
[i_pth, imain_name, imain_ext] = fileparts(imain);
[d_pth, datain_name, datain_ext] = fileparts(datain);

% deal with acqparam file
if ~strcmp(i_pth,d_pth), copyfile(datain,i_pth); end

% deal with topup spline coef file
if ~strcmp(i_pth,pth_tuc)
    fn_cp = ls(fullfile(pth_tuc,[topup,'*.nii.gz']));
    copyfile(fullfile(pth_tuc,deblank(fn_cp)),i_pth);
else
    fn_cp = ls(fullfile(i_pth,[topup,'*.nii.gz']));
end
fn_topup = fn_cp(1:end-7); % remove the .nii.gz extension

cmd = sprintf( ...
    ['applytopup --imain=%s --inindex=%s --datain=%s ', ...
     '--topup=%s --method=%s --interp=%s --out=%s --verbose'], ...
    [imain_name, imain_ext], ...
    inindex, ...
    [datain_name, datain_ext], ...
    fn_topup, ...
    method, interp, ...
    [b_out,imain_name] );

% call to fsl-topup
[status, cmd_out] = crc_fsl(cmd, i_pth);

% remove the topup spline coef splines
delete(fullfile(i_pth,fn_cp));

end
