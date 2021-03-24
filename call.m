clear all; close all; clc; %#ok<*CLALL>

%% Docker attributes
setenv('DOCKER_EXEC', 'docker');            % The command to run docker.
setenv('FSL_IMG', 'topup:6.0.3-20210212');  % The name of the topup image.

%% Prepares topup?
[status, cmd_out] = fsl('pwd', ...
    char('gen_fsl_docker.sh', 'gen_topup_docker.sh'), '.*'); % using regexp

%% Run topup
% list filename of input
fn_data = 'C:\3_Code\topup_docker\TestData\scr_prepare_testdata\derivatives\testTopUp\sub-s011\ses-baseline\fmap\sub-s011_ses-baseline_dir-PA_epi_4topup.nii.gz';
% fn_data = 'C:\3_Code\topup_docker\TestData\scr_prepare_testdata\derivatives\testTopUp\sub-s011\ses-baseline\fmap\sub-s011_ses-baseline_dir-PA_epi_4topup.nii';
fn_acqParam = 'C:\3_Code\topup_docker\TestData\acqparams.txt';
fn_cnf = 'C:\3_Code\topup_docker\TestData\b02b0.cnf';
% call
fsl_topup( ...
    fn_data, ...
    fn_acqParam, ...
    fn_cnf, ...
    'topup_results');

%% Apply topup
fn_data_cor = 'C:\3_Code\topup_docker\TestData\scr_prepare_testdata\derivatives\testTopUp\sub-s011\ses-baseline\func\sub-s011_ses-baseline_task-AXcpt_bold_2topup.nii.gz';
fn_acqParam = 'C:\3_Code\topup_docker\TestData\acqparams.txt';

fsl_applytopup( ...
    fn_data_cor, ...
    '1', ...
    fn_acqParam, ...
    'topup_results', ...
    'jac', ...
    'spline', ...
    'hifi_images');

%% TESTING new version

% Sanity check
[status, cmd_out] = fsl('pwd', [], '.*'); %#ok<*ASGLU> % using regexp

% TopUp Estimate
% ==============
% 4D volume with AP/PA data (2 vols each)
fn_data = 'C:\3_Code\topup_docker_data\TestData\fmap\sub-s011_ses-baseline_dir-PA_epi_4topup.nii';
% Parameter and config file
fn_acqParam = 'C:\3_Code\topup_docker_data\TestData\acqparams.txt';
fn_cnf      = 'C:\3_Code\topup_docker_data\TestData\b02b0.cnf';

% Call, with prefix 'TUsc_' & 'TUhf_' for the 2 output (spline coefs and 
% Hertz field)
[status, cmd_out] = crc_topup_estimate( ...
    fn_data, fn_acqParam, fn_cnf, char('TUsc_','TUhf_') );

% TopUp Apply
% ===========
fn_data_cor = 'C:\3_Code\topup_docker_data\TestData\func\sub-s011_ses-baseline_task-AXcpt_bold_2topup.nii';
fn_acqParam = 'C:\3_Code\topup_docker_data\TestData\acqparams.txt';
fn_topupSC  = 'C:\3_Code\topup_docker_data\TestData\fmap\TUsc_sub-s011_ses-baseline_dir-PA_epi_2topup_00001_4topup_fieldcoef.nii.gz';

[status, cmd_out] = crc_topup_apply( ...
    fn_data_cor, ... % data to correct
    fn_acqParam, ... % acquisition parameters
    '1', ...         % index for acquistion parameter line
    fn_topupSC, ...  % topup spline coeficients
    'jac', ...       % method to use
    'spline', ...    % interpolation method
    'TUw_');         % prefix of resulting file

%% Work on high-level functions

% Call to docker for checks
system('docker -v') % return the current version
system('docker-machine restart') % launch daemon
[status, cmd_out] = system('docker images') % 
system('docker start --help') % 
system('docker system info') % 

% Prepare 3D images for test
dData = 'C:\3_Code\topup_docker_data\TestData';
fn_fmap4D = spm_select('FPList',fullfile(dData,'fmap'),'^sub.*epi_2topup\.nii$');
fn_func4D = spm_select('FPList',fullfile(dData,'func'),'^sub.*bold_2topup\.nii$');

V_fmap3D = spm_file_split(fn_fmap4D, spm_file(fn_fmap4D,'path'));
V_func3D = spm_file_split(fn_func4D, spm_file(fn_func4D,'path'));

% Defining input images + acqparam + config
% fnD1 = char(V_fmap3D(:).fname); fnD2 = char(V_func3D(:).fname);
fnD1 = spm_select('FPList',fullfile(dData,'fmap'),'^sub.*epi_2topup_(\d+).nii$');
fnD2 = spm_select('FPList',fullfile(dData,'func'),'^sub.*bold_2topup_(\d+).nii$');
fnAcqpar = fullfile(dData,'fmap','acqparams.txt');
fnConfig = fullfile(dData,'fmap','b02b0.cnf');

% Call high-level function to estimate warps
[fn_TUsc, fn_TUhz] = crc_topup_WarpEstimate(fnD1,fnD2,fnAcqpar,fnConfig);

%% Check high-level functions and wrapper, with full func/fmap set

% get 4D files
pth_BIDSderiv = 'C:\3_Code\topup_docker_data\derivatives\testTopUp';
fn_func4D = spm_select('FPListRec',pth_BIDSderiv,'^sub-.*_bold\.nii$');
fn_fmap4D = spm_select('FPListRec',pth_BIDSderiv,'^sub-.*_epi\.nii$');
% split into 3D files
V_func3D = spm_file_split(fn_func4D, spm_file(fn_func4D,'path'));
V_fmap3D = spm_file_split(fn_fmap4D, spm_file(fn_fmap4D,'path'));
% Ditch the 1st 6 dummies
Ndum = 6;
pth_Dfunc = fullfile(spm_file(fn_func4D,'path'),'dummies'); mkdir(pth_Dfunc)
pth_Dfmap = fullfile(spm_file(fn_fmap4D,'path'),'dummies'); mkdir(pth_Dfmap)
for ii = 1:Ndum
    movefile( char(V_func3D(ii).fname), pth_Dfunc)
    movefile( char(V_fmap3D(ii).fname), pth_Dfunc)
end
fn_func3D = char(V_func3D(Ndum+1:end).fname);
fn_fmap3D = char(V_fmap3D(Ndum+1:end).fname);

% Estimate TopUp
pth_param = 'C:\3_Code\topup_docker_data';
fn_Acqpar = fullfile(pth_param,'acqparams.txt');
fn_Config = fullfile(pth_param,'b02b0.cnf');

fn_D1 = fn_func3D(1:2,:);
fn_D2 = fn_fmap3D(1:2,:);
[fn_TUsc, fn_TUhz] = crc_topup_WarpEstimate(fn_D1,fn_D2,fn_Acqpar,fn_Config);

% Apply TopUp
fn_uwD = crc_topup_WarpApply(fn_func3D, fn_Acqpar, fn_TUsc);


