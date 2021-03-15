function fn_uwD = crc_topup_WarpApply(fn_D, fn_Acqpar, fn_TUsc)
% High-level function to apply the topup unwarp to one set of images
% 
% INPUT
% fn_D       : set (char array) of 3D images to unwarp
% fn_Acqpar : filename of corresping acquisition parameters, where the 1st
%            line MUST match the data to correct in fn_D
% fn_TUsc   : filename of spline coeficients (.nii.gz image)
% 
% OUTPUT
% fnwd      : set (char array) of unwarped 3D images of images
% 
% NOTES
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Parameters
pref_uw = 'TUu_'; % prefix of resulting unwapred image file

%% Setup, Docker attributes
% -> should it be defined somewhere else or if at all?
setenv('DOCKER_EXEC', 'docker');            % The command to run docker.
setenv('FSL_IMG', 'topup:6.0.3-20210212');  % The name of the topup image.

%% Prepare images

%% Apply the warps
% Call to mid-level function to apply the unwarping

[status, cmd_out] = crc_topup_apply( ...
    fn_data_cor, ... % data to correct
    fn_Acqpar, ... % acquisition parameters
    '1', ...         % index for acquistion parameter line
    fn_TUsc, ...  % topup spline coeficients
    'jac', ...       % method to use
    'spline', ...    % interpolation method
    pref_uw);         % prefix of resulting file

% [status, cmd_out] = crc_topup_apply(fn_imain, fn_datain, inindex, ...
%     fn_topup, method, interp, b_out);

%% Unpack images

end