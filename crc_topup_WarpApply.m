function crc_topup_WarpApply(fn_data_cor, fn_acqParam, fn_topupSC)
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

[status, cmd_out] = crc_topup_apply( ...
    fn_data_cor, ... % data to correct
    fn_acqParam, ... % acquisition parameters
    '1', ...         % index for acquistion parameter line
    fn_topupSC, ...  % topup spline coeficients
    'jac', ...       % method to use
    'spline', ...    % interpolation method
    'TUw_');         % prefix of resulting file

% [status, cmd_out] = crc_topup_apply(fn_imain, fn_datain, inindex, ...
%     fn_topup, method, interp, b_out);

end