%% Apply TopUp, medium level function
% 
% This function calls "applytopup" from inside the docker image.
% Parameters
%   fn_imain  : path to the images (4D file) to correct.
%   fn_datain : path to the acquisition parameters file.
%   inindex   : relation between the list of files given by --imain and
%                   the acquisition parameters in my_acq_param.txt
%   fn_topup  : path to the estimated topup spline coeficients
%   method    : method to use (e.g. 'jac').
%   interp    : interpolation method (e.g. 'spline').
%   b_out     : prefix of the output files.
% Returns
%   status    : The exit code of the call.
%   cmd_out   : The stdout of the call.
% 
% References for the Apply TopUp tool:
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/ApplyTopupUsersGuide
% 
% NOTE:
% This function does NOT rely on any SPM function
% 
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

function [status, cmd_out] = crc_topup_apply(fn_imain, fn_datain, inindex, fn_topup, method, interp, b_out)

% Checking if parameters are in the data folder
[i_pth, imain_name, imain_ext] = fileparts(fn_imain);
[d_pth, datain_name, datain_ext] = fileparts(fn_datain);
[t_pth, topup_name, topup_ext] = fileparts(fn_topup);

% deal with acqparam file 
% -> copy it in the folder with the data to correct if not there yet
if ~strcmp(i_pth,d_pth)
    copyfile(fn_datain,i_pth);
end

% deal with topup spline coef file
% -> copy it in the folder with the data to correct if not there yet
if ~strcmp(i_pth,t_pth)
    copyfile(fn_topup,i_pth);
end

% TO BE CHECKED
fn_topup_loc = topup_name(1:end-4); % remove the .nii extension (.gz already in topup_ext)

% Create the applytopup command call
cmd = sprintf( ...
    ['applytopup --imain=%s --inindex=%s --datain=%s ', ...
     '--topup=%s --method=%s --interp=%s --out=%s --verbose'], ...
    [imain_name, imain_ext], ...
    inindex, ...
    [datain_name, datain_ext], ...
    fn_topup_loc, ...
    method, interp, ...
    [b_out,imain_name] );

% call to fsl-topup
[status, cmd_out] = crc_fsl(cmd, i_pth);

% remove the topup spline coef splines
delete(fullfile(i_pth, [topup_name, topup_ext]));

end
