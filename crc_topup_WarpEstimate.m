function [fn_TUsc, fn_TUhz] = crc_topup_WarpEstimate(fnD1,fnD2,fnAcqpar,fnConfig,dOut)
% High-level function to estimate the topup warps from 2 sets of image.
% 
% INPUT
% fnD1      : 1st set (char array) of 3D images (reverse PE)  -> 'fmap'
% fnD2      : 2nd set (char array) of 3D images (straight PE) -> 'func'
% fnAcqpar  : filename of corresping acquisition parameters of fnD1/2
% fnConfig  : filename of default TU config parameters
% dOut      : output folder [optional]
% 
% OUTPUT
% fn_TUsc   : filename of spline coeficients (.nii.gz image)
% fn_TUhz   : filename of field in Hertz (.nii.gz image)
% 
% NOTES
% 1/ The results and intermediary files are placed in the 'dOUT' folder. If
%   this one is not provided or left empty, then the folder of the 1st set 
%   of images is used. Therefore the recommended order for the images is to
%   set
%   - the "fmap" (i.e. reverse PE) as 1st set
%   - the "func" or "dwi" (i.e. straight PE) as 2nd set
% 2/ The acquisition parameter and config files are typically available in
%   the "fmap" folder.
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% No check on input for the moment

%% Parameters
pref_sc = 'TUsc_'; % estimated spline coeficients
pref_hf = 'TUhf_'; % estimated field in Hertz

%% Setup, Docker attributes
% -> should it be defined somewhere else or if at all?
setenv('DOCKER_EXEC', 'docker');            % The command to run docker.
setenv('FSL_IMG', 'topup:6.0.3-20210212');  % The name of the topup image.


%% Dealing with the output folder
if nargin<5 || isempty(dOut)
    % Define output folder as that of 1st set of images
    dOut = spm_file(fnD1(1,:),'fpath');
end
if ~exist(dOut,'dir'), mkdir(dOut); end

%% Combine the 2 sets of 3D images into a 4D image
fn_fmapfunc4D_topup = spm_file(fnD1(1,:),'suffix','_4topup');
V4fmapfunc4D_topup = spm_file_merge(char(fnD1,fnD2),fn_fmapfunc4D_topup); %#ok<*NASGU>

%% Estimate the warps
% Call to mid-level function to create the 2 output.
[status, cmd_out] = crc_topup_estimate( ...
    fn_fmapfunc4D_topup, fnAcqpar, fnConfig, char(pref_hf,pref_hf) );
if status
    err_msg = sprintf(['\nThere was a problem.', ...
        '\n\tHere is the error message collected:', ...
        '\n\t%s\n'],cmd_out);
    error('DockerTU:WarpEstimate',err_msg); %#ok<*SPERR>
end

fn_TUsc = spm_file(fn_fmapfunc4D_topup, ...
    'prefix',pref_sc, 'suffix','_fieldcoef', 'ext','.nii.gz');
fn_TUhz = spm_file(fn_fmapfunc4D_topup, 'prefix',pref_hf, 'ext','.nii.gz');

end
