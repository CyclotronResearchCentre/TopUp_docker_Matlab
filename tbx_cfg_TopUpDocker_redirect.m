function TUdocker = tbx_cfg_TopUpDocker_redirect
% Diversion config file for the TUdocker toolbox
%
% PURPOSE
% The present TUdocker config file redirects towards the full 
% implementation of the toolbox (tbx_cfg_TUdocker) only if present in the 
% Matlab path. 
% The toolbox can therefore be stored in a directory independent from the 
% SPM implementation and synch'd with the main TUdocker repository whenever
% needed. If tbx_cfg_TUdocker is not found in the Matlab path, the TUdocker
% tools are listed in the SPM Batch GUI but not available. A brief help 
% section provides the user with instructions for TUdocker installation.
%
% USAGE
% Copy this file into a directory in the SPM toolbox directory (e.g.
% <path-to-SPM>/toolbox/TUdocker). Add the TUdocker toolbox directory
% (containing the full implementation of the toolbox) to the Matlab path.
% Restart SPM and the Batch GUI. The TUdocker tools will be available in 
% the SPM->Tools menu.
%
% Warning and disclaimer: This software is for research use only.
% Do not use it for clinical or diagnostic purposes.
%
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

% Adapted from Evelyne Balteau (April 2017) and the hMRI toolbox

if ~isdeployed, addpath(fileparts(mfilename('fullpath'))); end

try
    % TUdocker is available
    TUdocker = tbx_cfg_TopUpDocker;
catch %#ok<CTCH>
    % No hMRI toolbox found
    TUdocker         = cfg_exbranch;
    TUdocker.tag     = 'TUdocker';
    TUdocker.name    = 'TUdocker Tools - not available!';
    TUdocker.help    = {
        ['The TUdocker toolbox does not seem to be available on this computer. ',...
        'The directory containing the toolbox implementation should be ',...
        'in the Matlab path to be used in SPM. See installation ',...
        'instructions on the TUdocker toolbox repository: ']
        'https://github.com/CyclotronResearchCentre/TopUp_docker_Matlab.'
        }';
    TUdocker.val  = {};
end

end

