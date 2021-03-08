function crc_topup_WarpApply
% High-level function to apply the topup unwarp to one set of images
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