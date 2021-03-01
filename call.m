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

[status, cmd_out] = fsl('pwd', [], '.*'); % using regexp


% 4D volume with AP/PA data (2 vols each)
fn_data = 'C:\3_Code\topup_docker_data\TestData\fmap\sub-s011_ses-baseline_dir-PA_epi_4topup.nii';
% Parameter and config file
fn_acqParam = 'C:\3_Code\topup_docker_data\TestData\acqparams.txt';
fn_cnf      = 'C:\3_Code\topup_docker_data\TestData\b02b0.cnf';

% Call, with prefix 'TUsc_' & 'TUhf_' for the 2 output (spline coefs and 
% Hertz field)
[status, cmd_out] = crc_topup_estimate( ...
    fn_data, fn_acqParam, fn_cnf, char('TUsc_','TUhf_') );

