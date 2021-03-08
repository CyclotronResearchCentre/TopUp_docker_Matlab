%% TopUp estimate
% This function calls topup from inside the docker image to estimate:
% - the deformation field (spline coefficients to be used with TopUpApply)
% - the field in Hz
% 
% Parameters
%   imain (char)  : full path to the image.
%   datain (char) : full path to the acquisition parameters file.
%   config (char) : full path to the config file.
%   b_out (char)  : [2xN] array with prefix of the output files
%                    (deformation coeficients & field in Hz)
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (char) : The stdout of the call.
% 
% References for the TopUp tool:
% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by M. Grignard & C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

function [status, cmd_out] = crc_topup_estimate(imain, datain, config, b_out)

% in_files = char(imain, datain, config);
[i_pth, imain_name, imain_ext] = fileparts(imain);
[d_pth, datain_name, datain_ext] = fileparts(datain);
[c_pth, config_name, config_ext] = fileparts(config);

% Check that parameter (datain) and config files are in the same folder as
% the images, copy them there
if ~strcmp(i_pth,d_pth), copyfile(datain,i_pth); end
if ~strcmp(i_pth,c_pth), copyfile(config,i_pth); end

% Output names are those of the images prefixed as requested and suffix
% imposed by TopUp itself
cmd = sprintf( ...
    'topup --imain=%s --datain=%s --config=%s --out=%s --fout=%s --verbose', ...
    [imain_name, imain_ext], ...
    [datain_name, datain_ext], ...
    [config_name, config_ext], ...
    [deblank(b_out(1,:)),imain_name], ...
    [deblank(b_out(2,:)),imain_name] );

[status, cmd_out] = crc_fsl(cmd, i_pth);
end
