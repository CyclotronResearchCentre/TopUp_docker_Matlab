function crc_topup_defaults
% Set the defaults which are used by the CRC TopUp add-on
%__________________________________________________________________________
%
% crc_topup_defaults should not be called directly in any "home made" 
% script or function (apart from the CRC TopUp internals).
% 
% To get/set the defaults, use crc_topup_get_defaults.
%
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Global variable for structure with TopUp defaults
global TUdef

%% TopUp estimate
% ===============
% Prefixes for estimated deformation
TUdef.pref_sc = 'TUsc_';   % for estimated spline coefficients
TUdef.pref_hf = 'TUfh_';   % for estimated field in Hertz
TUdef.suff_4D = '_4TUest'; % for 4D files with images in both PE directions

%% TopUp apply
% ============
% Flags
TUdef.fl_clean = true; % cleaning up (=deleting) of intermediate files
TUdef.fl_renumber_fn = true; % renumbering of the end files according to the 
                       % original indexing from 1st 4D->3D split
% Prefix of resulting unwapred image file
TUdef.pref_uw = 'u';     
% Suffix for the 4D file with images to correct
TUdef.suff_4D = '_4D';

%% TopUp wrapper for fMRI
% =======================
TUdef.N_fn = 2; 
% number of files to use at the beginning of each series
TUdef.rr_prefix = 'r_'; 
% prefix for reslicing of realigned fMRI, set to 'r_' (instead of 'r') for 
% BIDS compatibility.

%% Parameter files
% ================
% Configuration file for the estimation
TUdef.fn_cnf = fullfile(mfilename('fullpath'),'Parameters','b02b0.cnf');
% Could certainly be left as is.
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide#Configuration_files

% Acquisition parameter file MUST be adapted to your data
TUdef.fn_acq = fullfile(mfilename('fullpath'),'Parameters','acqparams.txt');
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide#A--datain

%% Environment variables, for the low level function
% =================================================
% TUdef.cmd_docker = 'docker'; -> only using docker so call is hardcoded
TUdef.Dimg_name = 'topup';
TUdef.Dimg_vers = '6.0.3-20210212';
TUdef.fsl_img = [TUdef.Dimg_name,':',TUdef.Dimg_vers];
TUdef.fl_save_shscr = true;

% Setup, Docker attributes
% setenv('DOCKER_EXEC', TUdef.cmd_docker); % The command to run docker.
% setenv('FSL_IMG', [TUdef.Dimg_name,':',TUdef.Dimg_vers]);  % The name of the topup image.

end