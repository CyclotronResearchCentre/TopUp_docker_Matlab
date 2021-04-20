function [fn_TUsc, fn_TUhz] = crc_topup_WarpEstimate(fn_D1, fn_D2, fn_Acqpar, fn_Config, dOut)
%% Estimate the topup warps from 2 sets of image,
% high-level function
% 
% INPUT
% fn_D1      : 1st set (char array) of 3D images (PE) -> 'func'
% fn_D2      : 2nd set (char array) of 3D images (reverse PE)  -> 'fmap'
% fn_Acqpar  : filename of corresping acquisition parameters of fn_D1/2
% fn_Config  : filename of default TopUp config parameters
% dOut      : output folder [optional]
% 
% OUTPUT
% fn_TUsc   : filename of spline coeficients (.nii.gz image)
% fn_TUhz   : filename of field in Hertz (.nii.gz image)
% 
% NOTES
% 1/ The results and intermediary files are placed in the 'dOUT' folder. If
%   this one is not provided or left empty, then the folder of the 2nd set 
%   of images is used. 
%   Therefore the recommended order for the images is to set
%   - the "func" or "dwi" (i.e. straight PE) as 1st set
%   - the "fmap" (i.e. reverse PE) as 2nd set
% 2/ The acquisition parameter and config files are typically available in
%   the "fmap" folder.
% 
% TO CHECK
% - If frames from a 4D image file are passed in fn_D1 ou fn_D2 instead or  
%   a list of 3D images, will this work?
% - Must check the input formats and match with the acquisition parameter
%   file
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% No check on input for the moment

%% Parameters
pref_sc = crc_topup_get_defaults('pref_sc'); % estimated spline coefficients
pref_hf = crc_topup_get_defaults('pref_hf'); % estimated field in Hertz
suff_4D  = crc_topup_get_defaults('suff_4D');% 4D files with images in both PE directions

% %% Setup, Docker attributes
% % -> should it be defined somewhere else or if at all?
% setenv('DOCKER_EXEC', 'docker');            % The command to run docker.
% setenv('FSL_IMG', 'topup:6.0.3-20210212');  % The name of the topup image.

%% Dealing with the output folder
if nargin<5 || isempty(dOut)
    % Define output folder as that of 1st set of images
    dOut = spm_file(fn_D2(1,:),'fpath');
end
if ~exist(dOut,'dir'), mkdir(dOut); end

%% Combine the 2 sets of 3D images into a 4D image for Topup estimate
% -> this file is suffixed with '_4TUest' and placed in 'dOut'
fn_fmapfunc4D_topup = spm_file(... 
    crc_rm_suffix(fn_D1(1,:),'_\d{5,5}$'), ... % removing trailing file index
    'suffix', suff_4D, 'path', dOut); % update suffix & path
V4fmapfunc4D_topup = spm_file_merge(char(fn_D1,fn_D2),fn_fmapfunc4D_topup); %#ok<*NASGU>

%% Estimate the warps
% Call to mid-level function to create the 2 output.
[status, cmd_out] = crc_topup_estimate( ...
    fn_fmapfunc4D_topup, fn_Acqpar, fn_Config, char(pref_sc,pref_hf) );

% Check if there was a problem and return error message
if status
    err_msg = sprintf(['\nThere was a problem.', ...
        '\n\tHere is the error message collected:', ...
        '\n\t%s\n'],cmd_out);
    error('DockerTU:WarpEstimate',err_msg); %#ok<*SPERR>
end

% Generate output filenames, as created by crc_topup_estimate
fn_TUsc = spm_file(fn_fmapfunc4D_topup, ...
    'prefix', pref_sc, 'suffix', '_fieldcoef', 'ext', '.nii.gz');
fn_TUhz = spm_file(fn_fmapfunc4D_topup, ...
    'prefix', pref_hf, 'ext', '.nii.gz');

%% Clean up the plate
% Should be removing the files that are not needed any more?
% - the 4D file created for the estimation
% - parameter and config files
% These are in the fmap folder and not so big
% -> not so much of a clutter...

end

