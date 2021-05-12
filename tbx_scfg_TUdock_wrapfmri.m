function TUwrapfmri = tbx_scfg_TUdock_wrapfmri
% Configuration file for the "TopUp Docker" fMRI wrapper module
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%--------------------------------------------------------------------------
% fmri_fn Session fmri data
%--------------------------------------------------------------------------
fmri_fn         = cfg_files;
fmri_fn.tag     = 'fmri_fn';
fmri_fn.name    = 'fMRI data';
fmri_fn.help    = {
    'Select fMRI scans for this session.'
    ['These are the all the functional MRIs for this session, encoded ', ...
    'with a known "Phase Encoding" direction.']
    }';
fmri_fn.filter  = 'image';
fmri_fn.ufilter = '.*';
fmri_fn.num     = [1 Inf];
fmri_fn.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% fmap_fn Session fmap data
%--------------------------------------------------------------------------
fmap_fn         = cfg_files;
fmap_fn.tag     = 'fmap_fn';
fmap_fn.name    = 'fmap data';
fmap_fn.help    = {
    'Select fmaps for this session.'
    ['These are the few images acquired with the oppositite "Phase Encoding', ...
    'direction, wrt. to the fMRIs.']
    }';
fmap_fn.filter  = 'image';
fmap_fn.ufilter = '.*';
fmap_fn.num     = [1 Inf];
fmap_fn.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% data Sessions
%--------------------------------------------------------------------------
data      = cfg_branch;
data.tag  = 'data';
data.name = 'Sessions';
data.val  = {fmri_fn fmap_fn};
data.help = {
    'Data to enter for each session: fMRI series + fmaps.'
    ['TopUp correction is first estimated from a set of 2 (by default ',...
    'but can be changed) images in each phase encoding direction.']
    ['Then in the coregistration step, the sessions are first realigned to ', ...
    'each other, by aligning the first scan from each session to the ', ...
    'first scan of the first session.  Then the images within each ', ...
    'session are aligned to the first image of the session. The parameter ', ...
    'estimation is performed this way because it is assumed (rightly or ', ...
    'not) that there may be systematic differences in the images between ', ...
    'sessions.']
    ['Finally TopUp correction is applied on the realigned (estimate & ', ...
    'reslice) fMRI data.']
    }';

%--------------------------------------------------------------------------
% generic Data
%--------------------------------------------------------------------------
generic        = cfg_repeat;
generic.tag    = 'generic';
generic.name   = 'Data';
generic.help   = {
    'Add new sessions for this subject.'
    ['In the coregistration step, the sessions are first realigned to ', ...
    'each other, by aligning the first scan from each session to the ', ...
    'first scan of the first session.  Then the images within each ', ...
    'session are aligned to the first image of the session. The parameter ', ...
    'estimation is performed this way because it is assumed (rightly or ', ...
    'not) that there may be systematic differences in the images between sessions.']
    }';
generic.values = {data};
generic.num    = [1 Inf];

%--------------------------------------------------------------------------
% fwhm Histogram Smoothing
%--------------------------------------------------------------------------
fwhm         = cfg_entry;
fwhm.tag     = 'fwhm';
fwhm.name    = 'Histogram Smoothing';
fwhm.help    = {
    'Gaussian smoothing to apply to the 256x256 joint histogram.'
    'Other information theoretic coregistration methods use fewer bins, but Gaussian smoothing seems to be more elegant.'
    }';
fwhm.strtype = 'r';
fwhm.num     = [1 2];
fwhm.def     = @(val)spm_get_defaults('coreg.estimate.fwhm', val{:});

%--------------------------------------------------------------------------
% fn_param Session fmap data
%--------------------------------------------------------------------------
fn_param         = cfg_files;
fn_param.tag     = 'fn_param';
fn_param.name    = 'Parameter file';
fn_param.help    = {
    'Select the parameter file.'
    ['These are the few images acquired with the oppositite "Phase Encoding', ...
    'direction, wrt. to the fMRIs.']
    }';
fn_param.filter  = 'image';
fn_param.ufilter = '.*';
fn_param.num     = [1 1];

%--------------------------------------------------------------------------
% options TU fMRI wrapper options
%--------------------------------------------------------------------------
options         = cfg_branch;
options.tag     = 'options';
options.name    = 'TU fMRI wrapper options';
options.val     = {fn_param fn_conifg N_PEfiles};
options.help    = {'Some parameter options.'};

%--------------------------------------------------------------------------
% TUwrapfmri Main TopUp wrapper for fMRI
%--------------------------------------------------------------------------
TUwrapfmri       =  cfg_exbranch;
TUwrapfmri.tag   = 'TUdocker';
TUwrapfmri.name  = 'Top Up docker -> fMRI wrapper';
TUwrapfmri.val   = {generic options};
% TUwrapfmri.check = @check_TUwrapfmri;
TUwrapfmri.help  = { 
    'Automatizing the processing of (multiple sessions of) fMRI series', ...
    'by combining the TopUp estimation & application, with SPM''s realign.'};
TUwrapfmri.prog  = @TUdock_run_wrapfmri;
TUwrapfmri.vout  = @vout_wrapfmri;


end
