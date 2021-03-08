function [a, b] = crc_topup_WarpEstimate(fnD1,fnD2,fnAcqpar,fnConfig,dOut)
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
% 
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

%% Setup, Docker attributes
setenv('DOCKER_EXEC', 'docker');            % The command to run docker.
setenv('FSL_IMG', 'topup:6.0.3-20210212');  % The name of the topup image.


%% No check on input for the moment

%% Dealing with the output folder
if nargin<5 || isempty(dOut)
    % Define output folder as that of 1st set of images
    dOut = spm_file(fnD1(1,:),'fpath');
end
if ~exist(dOut,'dir'), mkdir(dOut); end

%% Combine the 2 sets of 3D images into a 4D image
fn_fmapfunc4D_topup = spm_file(fnD1(1,:),'suffix','_4topup');
V4fmapfunc4D_topup = spm_file_merge(char(fnD1,fnD2),fn_fmapfunc4D_topup);


%% Estimate the warps
% 4D volume with AP/PA data (2 vols each)
% fn_data = 'C:\3_Code\topup_docker_data\TestData\fmap\sub-s011_ses-baseline_dir-PA_epi_4topup.nii';
% Parameter and config file
% fn_acqParam = 'C:\3_Code\topup_docker_data\TestData\acqparams.txt';
% fn_cnf      = 'C:\3_Code\topup_docker_data\TestData\b02b0.cnf';

% Call, with prefix 'TUsc_' & 'TUhf_' for the 2 output (spline coefs and 
% Hertz field)
[status, cmd_out] = crc_topup_estimate( ...
    fn_fmapfunc4D_topup, fnAcqpar, fnConfig, char('TUsc_','TUhf_') );


end
