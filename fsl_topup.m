%% TopUp
% This function calls topup from inside the docker image to estimate:
% - the deformation field (spline coefficients to be used with TopUpApply)
% - the field in Hz
% 
% Parameters
%   imain (char)  : full path to the image.
%   datain (char) : full path to the acquisition parameters file.
%   config (char) : full path to the config file.
%   b_out (char)  : [2xN] array with basename of the output files
%                    (deformation coeficients & field in Hz)
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (string) : The stdout of the call.
% 
% References for the TopUp tool:
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide
%__________________________________________________________________________
% Copyright (C) 2020 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2020.
% GIGA Institute, University of Liege, Belgium

function [status, cmd_out] = fsl_topup(imain, datain, config, b_out)

in_files = char(imain, datain, config);
%     in_files = [imain, datain, config];
[~, imain_name, imain_ext] = fileparts(imain);
[~, datain_name, datain_ext] = fileparts(datain);
[~, config_name, config_ext] = fileparts(config);
cmd = sprintf( ...
    'topup --imain=%s --datain=%s --config=%s --out=%s --fout=%s --verbose', ...
    [imain_name, imain_ext], ...
    [datain_name, datain_ext], ...
    [config_name, config_ext], ...
    deblank(b_out(1,:)), ...
    debalnk(b_out(2,:)) );

% create regexp filter for output files (--out and --fout)
filt_out = char( ...
    ['^', deblank(b_out(1,:)),'.*'], ...
    ['^', deblank(b_out(2,:)),'.*'] );
% call to fsl-topup
[status, cmd_out] = fsl(cmd, in_files, filt_out);
end
