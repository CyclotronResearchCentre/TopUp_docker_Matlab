function fn_uwd = crc_topup_WarpApply(fn_D, fn_Acqpar, fn_TUsc)
% High-level function to apply the topup unwarp to one set of images
% 
% INPUT
% fn_D      : set (char array) of 3D images to unwarp
% fn_Acqpar : filename of corresping acquisition parameters, where the 1st
%            line MUST match the data to correct in fn_D
% fn_TUsc   : filename of spline coeficients (.nii.gz image)
% 
% OUTPUT
% fn_uwd      : set (char array) of unwarped 3D images of images
% 
% NOTES
% The outputfile from the TopUp unwarping is in Float32 format, depsite the
% fact that input images are in Int16. Not sure if it matters but it would
% be nicer to avoid data bloating because of the format change...
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Parameters
pref_uw = 'TUu_'; % prefix of resulting unwapred image file
suff_4D = '_4D';  % suffix used for the 4D file with images to correct
flag_clean = true; % flag indicating the cleaning of intermediate files

%% Setup, Docker attributes
% -> should it be defined somewhere else or if at all?
setenv('DOCKER_EXEC', 'docker');            % The command to run docker.
setenv('FSL_IMG', 'topup:6.0.3-20210212');  % The name of the topup image.

%% Prepare images
% Use spm_file_merge function to 3D->4D pack the set of images
% removing the _01234 indexing suffix from spm_split

fn_data_2cor = spm_file( ...
    crc_rm_suffix(fn_D(1,:),'_\d{5,5}$'), ... % removing trailing file index,
    'suffix',suff_4D); % Adding 4D suffix
V4 = spm_file_merge(fn_D, fn_data_2cor); %#ok<*NASGU>

%% Apply the warps
% Call to mid-level function to apply the unwarping

[status, cmd_out] = crc_topup_apply( ...
    fn_data_2cor, ... % data to correct
    fn_Acqpar, ... % acquisition parameters
    '1', ...         % index for acquistion parameter line
    fn_TUsc, ...  % topup spline coeficients
    'jac', ...       % method to use
    'spline', ...    % interpolation method
    pref_uw);         % prefix of resulting file

% Wheck if there was a problem and return error message
if status
    err_msg = sprintf(['\nThere was a problem.', ...
        '\n\tHere is the error message collected:', ...
        '\n\t%s\n'],cmd_out);
    error('DockerTU:WarpEstimate',err_msg); %#ok<*SPERR>
end

if flag_clean, delete(fn_data_2cor), end

%% Unpack images
% Use spm_file_split.m function to 4D->3D split the set of images
% but first need to unzip the resulting file
fn_data_cord = spm_file(fn_data_2cor,'prefix',pref_uw);
fn_data_cord_gz = [fn_data_cord,'.gz'];
gunzip(fn_data_cord_gz)

% Renaming the 4D file *without* suffix, 
% for shorter/simpler file naming after splitting back in 3D
fn_data_cord_nosf = crc_rm_suffix(fn_data_cord,[suff_4D,'$']);
movefile(fn_data_cord,fn_data_cord_nosf)

% Split back in 3D
Vo = spm_file_split(fn_data_cord_nosf);
fn_uwd = char(Vo(:).fname);

% Cleaning, if requested
if flag_clean 
    delete(fn_data_cord_gz)
    delete(fn_data_cord_nosf)
end

end