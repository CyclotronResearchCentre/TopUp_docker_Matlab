function TUdocker = tbx_cfg_TopUpDocker
% Configuration file for the "TopUp Docker" toolbox
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','TopUpDocker')); end

% The toolbox is currently split into 3 separate modules
% - TopUp estimate -> tbx_scfg_TUdock_estim
% - TopUp apply -> tbx_scfg_TUdock_apply
% - TopUp wrapper for fMRI -> tbx_scfg_TUdock_wrapfmri


% ---------------------------------------------------------------------
% TUdocker TopUp Docker Tools
% ---------------------------------------------------------------------
TUdocker         = cfg_choice;
TUdocker.tag     = 'TUdocker';
TUdocker.name    = 'Top Up docker Tools';
TUdocker.help    = {
    'This toolbox is about the TopUp method to correct fMRI and DWI data.'
    ['It includes 3 modules at the moment to: "TopUp estimate" to ', ...
    'estimate the correction in one subset of fMRI/DWI set of images, ', ...
    'TopUp apply to apply the estimated correction on the full set of ', ...
    'fMRI/DWI images, the "TopUp fMRI wrapper" for the full processing ', ...
    'of (possibly multiple sessions) fMRI data with TU-estimate, ',...
    'realignment, and TU-application.']
    }';
TUdocker.values  = {tbx_scfg_TUdock_estim tbx_scfg_TUdock_apply tbx_scfg_TUdock_wrapfmri};
end


