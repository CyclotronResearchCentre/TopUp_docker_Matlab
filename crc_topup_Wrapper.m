function [fn_urfunc, fn_func_rp, fn_umean] = crc_topup_Wrapper(fn_func, fn_fmap, fn_Acqpar, fn_Config, N_fn)
%% Wrapper for fmri/fmap data
% 
% The function automatizes the processing by taking as input the set of
% many functional images to unwarp & realign, with a few "fieldmap" images
% with the phase-encdoding in the opposite direction.
%
% This wraps arround the other 2 high-level functions:
% - crc_topup_WarpEstimate : estimate the warps from 2 sets of images
% - crc_topup_WarpApply    : apply the warps on one set of images
% as well as 2 functions from SPM, in between the TopUp estimate & apply:
% - spm_realign \_ to realign and reslice the images
% - spm_reslice /
%
% The processing consits in 3 main steps, relying on the other 2 high-level
% functions, 'crc_topup_WarpEstimate' & 'crc_topup_WarpApply' and SPM:
% 1. estimate the warps with a couple of images from 2 sets of images,
%   functional and fieldmaps.
% 2. realign, "estimate & write", the whole set of functional images
% 3. apply the estimated warps onto the realigned images
% 
% For multiple fMRI sessions, each session must include both an fMRI series
% and "fieldmap" images (with opposite PE direction). The processing will
% be the same as for a single session, except for the SPM realignment, with
% "estimate & write", where all essions are realigned together generating a
% single mean image. The acquisition parameter and config files are assumed
% to be the same for all the sessions.
%
% INPUT
% fn_func   : char array of filenames of the functional images to correct,
%             or cell array of these for multiple sessions
% fn_fmap   : char array of filenames of the fieldmap images, with the
%             PE direction in opposite direction of the functional data,
%             or cell array of these for multiple sessions
% fn_Acqpar : filename of the acquisition parameter
% fn_Config : filename of the config file for TopUp
% N_fn      : Number of files to use for fun & fmap data TopUp estimate. 
%             This should absolutely match the rows in fn_Acqpar ! 
%
% OUTPUT
% fn_urfunc  : char array of filenames of the functional images after
%              realignement and topup unwarping, or cell array of these for 
%              multiple sessions
% fn_func_rp : char array of the filenames of the realignement parameters
%              for each session
% fn_umean   : filename of the unwarped mean functional image, if it was
%              created during the realignment.
%
% NOTES
% So far the code considers that N_fn(1) func and N_fn(2) fmap images (set 
% as default parameter) should be used for the TU estimates, which MUST 
% correspond to the acquisition parameters in the acquisition parameter 
% (fn_Acqpar) file!
% 
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Parameters & checks
if nargin<5
    N_fn = crc_topup_get_defaults('N_fn'); 
    % number of files to be used in each PE direction, picked at the beginning
    warning('DockerTU:wrapper','Using default number of PE files :\n\t%d %d\n',N_fn);
end
if nargin<4 || ~exist(fn_Config,'file')
    fn_Config = crc_topup_get_defaults('fn_cnf');
    warning('DockerTU:wrapper','Using default config file :\n\t%s\n',fn_Config);
end
if nargin<3 || ~exist(fn_Acqpar,'file')
    fn_Acqpar = crc_topup_get_defaults('fn_acq');
    warning('DockerTU:wrapper','Using default acquisition file :\n\t%s\n',fn_Acqpar);
end

fl_param = check_params(fn_Acqpar,N_fn); % true if OK
if ~fl_param
    error('DockerTU:Wrapper', ...
        'Mismatched number of files and lines in acquisition parameter file.');
end

%% Estimate the warps from a subset of func & fmap images

% Deal with single vs. multiple sessions
if iscell(fn_func) && iscell(fn_fmap)
    N_sess = numel(fn_func);
    if N_sess ~= numel(fn_fmap)
        err_msg = sprintf(['\nInput mismatch for data.', ...
        '\n\tThere are %d "func" vs %d "fmap" sets!\n'], ...
        N_sess, numel(fn_fmap));
        error('DockerTU:fMRIWrapper',err_msg) %#ok<*SPERR>
    end
    fn_func_c = fn_func;
    fn_fmap_c = fn_fmap;
    fl_char = false;
elseif ischar(fn_func) && ischar(fn_fmap)
    N_sess = 1;
    fn_func_c{1} = fn_func;
    fn_fmap_c{1} = fn_fmap;
    fl_char = true;
else
    error('DockerTU:fMRIWrapper','\nInput mismatch for data.\n')
end

% Loop through the sessions
fn_TUsc = cell(N_sess,1);
for i_sess = 1:N_sess
    % Pick N_fn func and fmap images
    fn_D1 = fn_func_c{i_sess}(1:N_fn(1),:);
    fn_D2 = fn_fmap_c{i_sess}(1:N_fn(2),:);

    fn_TUsc{i_sess} = crc_topup_WarpEstimate(fn_D1, fn_D2, ...
        fn_Acqpar, fn_Config);
end

%% Realign and resample the functional data
% for the moment, using all the default parameters except for prefix, set
% to 'r_' instead of 'r' for BIDS compatibility.
rr_prefix = crc_topup_get_defaults('rr_prefix');

% Estimate realignement and resample
spm_realign(fn_func_c);
spm_reslice(fn_func_c,struct('prefix',rr_prefix)) 
% get the name of 
% - realigned and resliced functional images
% - estimated realignement parameters .txt file
fn_func_c_rr = cell(N_sess,1);
fn_func_c_rp = cell(N_sess,1);
for i_sess = 1:N_sess
    fn_func_c_rr{i_sess} = spm_file(fn_func_c{i_sess},'prefix',rr_prefix);
    fn_func_c_rp{i_sess} = spm_file(fn_func_c{i_sess}(1,:), ...
        'prefix','rp_', 'ext','.txt');
end
fn_func_rp = char(fn_func_c_rp);

fn_func_mean = spm_file(fn_func_c{1}(1,:),'prefix','mean','number','');
if ~exist(fn_func_mean,'file')
    fn_func_mean = [];
    % in case it was not created...
end

%% Apply the warps on r&r functional images
% Call to mid-level function to apply the unwarping,
fn_urfunc_c = cell(N_sess,1);
for i_sess = 1:N_sess
    if i_sess==1 && ~isempty(fn_func_mean)
        % deal with 1st session + mean, if possible
        fn_D = char( fn_func_c_rr{i_sess} , fn_func_mean); %#ok<*USENS> 
        [fn_urfunc_c{i_sess}, fn_umean] = ...
            crc_topup_WarpApply(fn_D, fn_Acqpar, fn_TUsc{i_sess}, 1);
    else
        fn_urfunc_c{i_sess} = ...
            crc_topup_WarpApply( ...
                fn_func_c_rr{i_sess}, fn_Acqpar, fn_TUsc{i_sess}, 0);
        if i_sess==1
            fn_umean = []; % no unwarped mean returned
        end
    end
end

%% Format output, as input
if fl_char
    % return char arrays if input was a char array, i.e. single session
    fn_urfunc = char(fn_urfunc_c);
else
    fn_urfunc = fn_urfunc_c;
end

end

%% SUBFUNCTION

%% Check the number of files passed for TU estimation
% and the acquisition parameter file

function fl_param = check_params(fn_Acqpar,N_fn)
% Checking if the acquisition parameter matches the number of files to be 
% used for each PE direction, using 2 criteria:
% - there should be as many lines as number of files for both PE directions
% - the number of lines in each PE direction, *assuming Y direction only*,
%   should match number of PE=1/-1 rows in the acquisition parameter.

% Assume it's OK
fl_param = true;

% Load acquisition parameters
acqpar = spm_load(fn_Acqpar);
N_PE(1) = numel(find(acqpar(:,2)==acqpar(1,2))); % 1st set
N_PE(2) = numel(find(acqpar(:,2)==acqpar(N_PE(1)+1,2))); % 2nd set

% There should be twice as many lines as number of files per PE direction
if size(acqpar,1)~=sum(N_fn) || N_PE(1)~=N_fn(1) || N_PE(2)~=N_fn(2)
    fl_param = false;  
end

end