%% TopUp estimate, low level function
% 
% This function calls topup from inside the docker image to estimate:
% - the deformation field (spline coefficients to be used with TopUpApply)
% - the field in Hz
% 
% Parameters
%   fn_imain  : full path to the images, 4D nifti with both PE directions
%   fn_datain : full path to the acquisition parameters file
%   fn_config : full path to the config file
%   b_out     : [2xN] array with prefix of the output files
%                    (deformation coeficients & field in Hz)
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (char) : The stdout of the call.
% 
% References for the TopUp tool:
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide
% 
% NOTE:
% This function does NOT rely on any SPM function
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

function [status, cmd_out] = crc_topup_estimate(fn_imain, fn_datain, fn_config, b_out)

% Split full filenames to get 
% - the pathes -> check and make sure everything is the same folder
% - the filenames -> call the topup estimate
[i_pth, imain_name, imain_ext] = fileparts(fn_imain);
[d_pth, datain_name, datain_ext] = fileparts(fn_datain);
[c_pth, config_name, config_ext] = fileparts(fn_config);

% Check that parameter (fn_datain) and config (config) files are in the 
% same folder as the images, copy them there
if ~strcmp(i_pth,d_pth), copyfile(fn_datain,i_pth); end
if ~strcmp(i_pth,c_pth), copyfile(fn_config,i_pth); end

% Output names are those of the images prefixed as requested and suffix
% imposed by TopUp itself
cmd = sprintf( ...
    'topup --imain=%s --datain=%s --config=%s --out=%s --fout=%s --verbose', ...
    [imain_name, imain_ext], ...
    [datain_name, datain_ext], ...
    [config_name, config_ext], ...
    [deblank(b_out(1,:)),imain_name], ...
    [deblank(b_out(2,:)),imain_name] );

[status, cmd_out] = crc_fsl(cmd, i_pth);
end
