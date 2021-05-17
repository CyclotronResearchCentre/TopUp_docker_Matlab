function TUwrapfmri = tbx_scfg_TUdock_wrapfmri
% Configuration file for the "TopUp Docker" fMRI wrapper module
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%--------------------------------------------------------------------------
% fn_fmri Session fmri data
%--------------------------------------------------------------------------
fn_fmri         = cfg_files;
fn_fmri.tag     = 'fn_fmri';
fn_fmri.name    = 'fMRI data';
fn_fmri.help    = {
    'Select fMRI scans for this session.'
    ['These are the all the functional MRIs for this session, encoded ', ...
    'with a known "Phase Encoding" (PE) direction.']
    }';
fn_fmri.filter  = 'image';
fn_fmri.ufilter = '.*';
fn_fmri.num     = [1 Inf];
fn_fmri.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% fn_fmap Session fmap data
%--------------------------------------------------------------------------
fn_fmap         = cfg_files;
fn_fmap.tag     = 'fn_fmap';
fn_fmap.name    = 'fmap data';
fn_fmap.help    = {
    'Select fmaps for this session.'
    ['These are the few images acquired with the oppositite "Phase Encoding', ...
    ' (PE) direction, wrt. to the fMRIs.']
    }';
fn_fmap.filter  = 'image';
fn_fmap.ufilter = '.*';
fn_fmap.num     = [1 Inf];
fn_fmap.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% data Sessions
%--------------------------------------------------------------------------
data      = cfg_branch;
data.tag  = 'data';
data.name = 'Sessions';
data.val  = {fn_fmri fn_fmap};
data.help = {
    'Data to enter for each session: fMRI series + fmaps.'
    ['TopUp correction is first estimated from a set of 2 (by default ',...
    'but can be changed) images in each "Phase Encoding" (PE) direction.']
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
    ['TopUp unwapring is performed per session, with the TU estimation ', ...
    'before and the TU application after the realignment step.']
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
% N_PEfiles Histogram Smoothing
%--------------------------------------------------------------------------
N_PEfiles         = cfg_entry;
N_PEfiles.tag     = 'N_PEfiles';
N_PEfiles.name    = 'Number of PE files';
N_PEfiles.help    = {
    'Number of files per "Phase Encoding" (PE) direction.'
    ['This is the number of files that will be picked in each image set ', ...
    'with opposite PE encoding direction. This should ABSOLUTELY match ', ...
    'the number of lines for each PE in the parameter file.']
    }';
N_PEfiles.strtype = 'r';
N_PEfiles.num     = [1 2];
N_PEfiles.def     = @(val)crc_topup_get_defaults('N_fn', val{:});

%--------------------------------------------------------------------------
% fn_param Session fmap data
%--------------------------------------------------------------------------
fn_param         = cfg_files;
fn_param.tag     = 'fn_param';
fn_param.name    = 'Parameter file';
fn_param.help    = {
    'Select the parameter file.'
    ['This file contains the acquisition parameters for the ''N_PEfiles'' ', ...
    'to be used in each PE direction. The number of rowss in the parameter ', ...
    'file should does be equal to the sum of ''#PE files'' value.']
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
% options TU fMRI wrapper options
%--------------------------------------------------------------------------
options         = cfg_branch;
options.tag     = 'options';
options.name    = 'TU fMRI wrapper options';
options.val     = {fn_param fn_config N_PEfiles};
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
TUwrapfmri.prog  = @run_wrapfmri;
TUwrapfmri.vout  = @vout_wrapfmri;

end

%==========================================================================
function dep = vout_wrapfmri(job)
% TopUp job output collection function

for k=1:numel(job.data)
    cdep(1)            = cfg_dep;
    cdep(1).sname      = sprintf('Realignment Param File (Sess %d)', k);
    cdep(1).src_output = substruct('.','fn_func_rp', '{}',{k});
    cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
    cdep(2)            = cfg_dep;
    cdep(2).sname      = sprintf('Realigned & Unwarped Images (Sess %d)', k);
    cdep(2).src_output = substruct('.','fn_urfunc', '{}',{k});
    cdep(2).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
    if k == 1
        dep = cdep;
    else
        dep = [dep cdep]; %#ok<*AGROW>
    end
end

% Was mean image created, according to default settings?
def_opt_realign_write = spm_get_defaults('realign.write.which');
if def_opt_realign_write(2)
    dep(end+1)          = cfg_dep;
    dep(end).sname      = 'Unwarped Mean Image';
    dep(end).src_output = substruct('.','fn_umean');
    dep(end).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
end

end

%==========================================================================
function out = run_wrapfmri(job)
% TopUp job execution function
% takes a harvested job data structure and call TU wrapper functions to
% perform computations on the data.
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
% OUTPUT
%   out    - computation results, usually a struct variable.

% Re-organize the func/fmap data in 2 separate cell arrays
[fn_func,fn_fmap] = reorganize_data(job);

% Do the job
[fn_urfunc, fn_func_rp, fn_umean] = crc_topup_Wrapper( ...
    fn_func, ...
    fn_fmap, ...
    job.options.fn_param{1}, ...
    job.options.fn_config{1}, ...
    job.options.N_PEfiles);

% Collect output
out.fn_urfunc = fn_urfunc;
out.fn_func_rp = fn_func_rp;
if ~isempty(fn_umean)
    out.fn_umean = fn_umean;
    % the field will not exist if no mean image created
end

end

%==========================================================================
function [fn_func,fn_fmap] = reorganize_data(job)
% Re-organize the func/fmap data in 2 separate cell arrays

N_sess = numel(job.data);
fn_func = cell(N_sess,1);
fn_fmap = cell(N_sess,1);
for kk=1:N_sess
    fn_func{kk} = char(job.data(kk).fn_fmri);
    fn_fmap{kk} = char(job.data(kk).fn_fmap);
end

end
