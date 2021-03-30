function [fn_urfunc, fn_umean] = crc_topup_Wrapper(fn_func,fn_fmap, fn_Acqpar, fn_Config)
% Function to automatize the processing by taking as input the set of
% many functional images to unwarp & realign, plus a few "fieldmap" images 
% with the phase-encdoding in the opposite direction.
% 
% This wraps arround the other 2 high-level functions:
% - crc_topup_WarpEstimate : estimate the warps from 2 sets of images
% - crc_topup_WarpApply    : apply the warps on one set of images
% 
% The processing consits in 3 main steps, relying on the other 2 high-level
% functions, 'crc_topup_WarpEstimate' & 'crc_topup_WarpApply' and SPM:
% 1. estimate the warps with a couple of images from 2 sets of images,
%   functional and fieldmaps.
% 2. realign, "estimate & write", the whole set of functional images
% 3. apply the estimated warps onto the realigned images
% 
% INPUT
% fn_func     : char array of filenames of the functional images to correct
% fn_fmap     : char array of filenames of the fieldmap images, with the 
%               PE direction in opposite direction of the functional data
% fn_Acqpar   : filename of the acquisition parameter
% fn_Config   : filename of the config file for TopUp
% 
% OUTPUT
% fn_urfunc   : char array of filenames of the functional images after
%               realignement and topup unwarping
% 
% NOTES
% So far the code considers that 2 func and 2 fmap images should be used
% for the TU estimates, which MUST correspond to the acquisition parameters
% in the fn_Acqpar file!
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Estimate the warps from a subset of func & fmap images 
% Pick 2 func and fmap images 
fn_D1 = fn_func(1:2,:);
fn_D2 = fn_fmap(1:2,:);

fn_TUsc = crc_topup_WarpEstimate(fn_D1, fn_D2, fn_Acqpar, fn_Config);

%% Realign and resample the functional data
% for the moment, using all the default parameters except for prefix, set 
% to 'r_' instead of 'r' for BIDS compatibility.
rr_prefix = 'r_';

% Estimate realignement and resample
spm_realign(fn_func);
spm_reslice(fn_func,struct('prefix',rr_prefix)) % with 'r_' prefix
% get the name of realigned and resliced functional images
fn_func_rr = spm_file(fn_func,'prefix',rr_prefix);
fn_func_mean = spm_file(fn_func(1,:),'prefix','mean');

%% Apply the warps on r&r functional images
% Call to mid-level function to apply the unwarping, 
% indicating that last volume is the mean
fn_D = char(fn_func_rr , fn_func_mean); % functional + mean
[fn_urfunc, fn_umean] = crc_topup_WarpApply(fn_D, fn_Acqpar, fn_TUsc, 1);

end