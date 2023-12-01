function TUestim = tbx_scfg_TUdock_estim
% Configuration file for the "TopUp Docker" estimation module
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%--------------------------------------------------------------------------
% fn_fmri Session fmri data -> just a few volumes
%--------------------------------------------------------------------------
fn_fmri         = cfg_files;
fn_fmri.tag     = 'fn_fmri';
fn_fmri.name    = 'fMRI data';
fn_fmri.help    = {
    'Select a few fMRI scans for this session.'
    ['These are the few reference functional MRIs, encoded ', ...
    'with a known "Phase Encoding" (PE) direction, to estimate the ', ...
    'the field inhomogenity.']
    }';
fn_fmri.filter  = 'image';
fn_fmri.ufilter = '.*';
fn_fmri.num     = [1 Inf];
fn_fmri.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% fn_fmap Session fmap data -> just a few volumes
%--------------------------------------------------------------------------
fn_fmap         = cfg_files;
fn_fmap.tag     = 'fn_fmap';
fn_fmap.name    = 'fmap data';
fn_fmap.help    = {
    'Select a few fmaps for this session, with inverted Phase Encoding.'
    ['These are the few images acquired with the oppositite "Phase Encoding', ...
    ' (PE) direction, wrt. to the fMRIs, to estimate the ', ...
    'the field inhomogenity.']
    }';
fn_fmap.filter  = 'image';
fn_fmap.ufilter = '.*';
fn_fmap.num     = [1 Inf];
fn_fmap.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% fn_param Session fmap data
%--------------------------------------------------------------------------
fn_param         = cfg_files;
fn_param.tag     = 'fn_param';
fn_param.name    = 'Parameter file';
fn_param.help    = {
    'Select the parameter file.'
    ['This file contains the acquisition parameters for the ''N_PEfiles'' ', ...
    'to be used in each PE direction. The number of rows in the parameter ', ...
    'file should be equal to the number of ''#PE files'' value.']
    }';
fn_param.filter  = 'mat'; % Matlab .mat files or .txt files (assumed to contain
%                      ASCII representation of a 2D-numeric array)
fn_param.ufilter = '.*';
fn_param.num     = [1 1]; % just 1
fn_param.val     = {{crc_topup_get_defaults('fn_acq')}};

%--------------------------------------------------------------------------
% fn_config TopUp config file
%--------------------------------------------------------------------------
fn_config         = cfg_files;
fn_config.tag     = 'fn_config';
fn_config.name    = 'Config file';
fn_config.help    = {
    'Select the config file.'
    ['The default file comes from the official TopUp distribution, ', ...
    'the predefined ''b02b0.cnf'' file.']
    'See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide#Configuration_files'
    }';
fn_config.filter  = 'any'; % as it's a .cnf file, typically b02b0.cnf
fn_config.ufilter = '.*\.cnf$';
fn_config.num     = [1 1]; % just 1
fn_config.val     = {{crc_topup_get_defaults('fn_cnf')}};

%--------------------------------------------------------------------------
% dOut Output folder for the results
%--------------------------------------------------------------------------
% No choice (for the moment) for the output folder
% -> use the folder from the 2 set of images, i.e. 'f_map'.

%--------------------------------------------------------------------------
% TUestim Main TopUp correction estimation for fMRI
%--------------------------------------------------------------------------
TUestim       =  cfg_exbranch;
TUestim.tag   = 'TUdocker';
TUestim.name  = 'Top Up docker -> fMRI wrapper';
TUestim.val   = {generic options};
% TUestim.check = @check_TUestim;
TUestim.help  = { 
    'Automatizing the processing of (multiple sessions of) fMRI series', ...
    'by combining the TopUp estimation & application, with SPM''s realign.'};
TUestim.prog  = @run_TUestim;
TUestim.vout  = @vout_TUestim;

end

%==========================================================================
function dep = vout_TUestim(job)
% Estimate the topup warps from 2 sets of image,
% 
% OUTPUT
% fn_TUsc   : filename of spline coeficients (.nii.gz image)
% fn_TUhz   : filename of field in Hertz (.nii.gz image)


% dep(1)            = cfg_dep;
% dep(1).sname      = 'Spline coeficients image';
% dep(1).src_output = substruct('.','sess', '()',{kk},'.','fn_func_rp');
% dep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
% 
% dep(2)            = cfg_dep;
% dep(2).sname      = 'Field in Hertz image';
% dep(1).src_output = substruct('.','sess', '()',{kk},'.','fn_func_rp');
% dep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});

end

%==========================================================================
function out = run_TUestim(job)
% TopUp job execution function
% takes a harvested job data structure and call TU Warp Estimate
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
% OUTPUT
%   out    - computation results, usually a struct variable.

% % Re-organize the func/fmap data in 2 separate cell arrays
% [fn_func,fn_fmap] = reorganize_data(job);
% 
% % Do the job
% [fn_urfunc, fn_func_rp, fn_umean] = crc_topup_Wrapper( ...
%     fn_func, ...
%     fn_fmap, ...
%     job.options.fn_param{1}, ...
%     job.options.fn_config{1}, ...
%     job.options.N_PEfiles);
% 
% % Collect output
% for ii=1:numel(job.data)
%     out.sess(ii).fn_urfunc  = cellstr(fn_urfunc);
%     out.sess(ii).fn_func_rp = cellstr(fn_func_rp);
% end
% if ~isempty(fn_umean)
%     out.fn_umean{1} = fn_umean;
%     % the field will be empty if no mean image created
% end

end


