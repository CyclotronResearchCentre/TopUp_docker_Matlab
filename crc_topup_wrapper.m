function crc_topup_wrapper
% Function to automatize the processing by taking as input the set of
% many functional images to unwarp & realign, plus a few "fieldmap" images 
% with the phase-encdoding in the opposite direction.

% to wrap arround the other 2 high-level functions:
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
% 
% INPUT
% 
% OUTPUT
% 
% NOTES
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Apply the warps
% Call to mid-level function to apply the unwarping
[status, cmd_out] = crc_topup_apply(imain, inindex, datain, topup, ...
    method, interp, b_out,pth_tuc);

end