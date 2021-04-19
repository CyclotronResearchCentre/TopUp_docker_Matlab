function [fn_uwd, fn_umean] = crc_topup_WarpApply(fn_D, fn_Acqpar, fn_TUsc, fl_mean)
% High-level function to apply the topup unwarp to one set of images.
% Takes in the bunch of images to correct an "acquisition parameter" file
% whose 1st line match that of the data to correct, and the spline
% coeficient image. 
% If a mean image is included as the last image of the series, then it is
% recovered on its own at then end if the flag is set to 1!
% 
% There is some issue with as the process needs repackaging data 3D series 
% into 4D file then back into a 3D series. This would clutter the resulting
% filename with multiple suffixes: 1st 3D index from 1st 4D->3D splitting, 
% suffix used for the 4D file, and 2nd 3D index from 3nd 4D->3D splitting. 
% So the code cleans up the suffixes as much as possible, removing the 1st 
% 3D index (if possible) and 4D file suffixes. Plus trying to reset the 2nd
% 3D index to that of the 1st 3D index.
% 
% INPUT
% fn_D      : set (char array) of 3D images to unwarp
% fn_Acqpar : filename of corresping acquisition parameters, where the 1st
%             line MUST match the data to correct in fn_D
% fn_TUsc   : filename of spline coeficients (.nii.gz image)
% fl_mean   : flag indicating the mean image is last of the seris
% 
% OUTPUT
% fn_uwd      : set (char array) of unwarped 3D images of images
% fn_umean    : filename of unwarped mean image
% 
% NOTES
% - The output file from the TopUp unwarping is in Float32 format, despite 
%   the fact that input images are in Int16. Not sure if it matters but it 
%   would be nicer to avoid data bloating because of the format change...
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% Flags
fl_clean = true; % cleaning up (=deleting) of intermediate files
fl_renumber_fn = true; % renumbering of the end files according to the 
                       % original indexing from 1st 4D->3D split
if nargin<4,
    % assume the last image of the input series is just another image and 
    % NOT the mean image from realign & reslice
    fl_mean = false;
end

%% Parameters & checks
pref_uw = 'u'; % prefix of resulting unwapred image file
suff_4D = '_4D';  % suffix used for the 4D file with images to correct

if nargout==2 && ~fl_mean
    warning('Topup:Apply', ...
        'The mean file is not flagged up so the returned filename will be empty!');
end

%% Setup, Docker attributes
% -> should it be defined somewhere else or if at all?
setenv('DOCKER_EXEC', 'docker');            % The command to run docker.
setenv('FSL_IMG', 'topup:6.0.3-20210212');  % The name of the topup image.

%% Prepare images
% Removing the '_01234' indexing suffix (from spm_split) on 1st volume to
% build the 4D filename, with '_4D' suffix.

[fn_D_nosf,sf_D] = crc_rm_suffix(fn_D(1,:),'_\d{5,5}$'); 
fn_data_2cor = spm_file(  fn_D_nosf, 'suffix',suff_4D); % Adding 4D suffix
% Then get value of 1st index 
if ~isempty(sf_D)
    startId_fn_D = str2double(sf_D(2:end));
end    
% Use spm_file_merge function to 3D->4D pack the set of images
V4 = spm_file_merge(fn_D, fn_data_2cor); %#ok<*NASGU>

if fl_mean % deal with mean image as last of series
    fn_mean = fn_D(end,:);
end

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

if fl_clean, delete(fn_data_2cor), end

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

% Deal with mean, if requested
if fl_mean
    % move (=rename) mean file
    fn_umean = spm_file(fn_mean,'prefix',pref_uw);
    movefile(fn_uwd(end,:),fn_umean);
    % clean up the list
    fn_uwd(end,:) = [];
else
    fn_umean = [];
end

% Reset indexes as in original series, if requested and possible
if fl_renumber_fn && ~isempty(startId_fn_D)
    fn_uwd = crc_renumber_fn(fn_uwd,struct('idshift',startId_fn_D-1));
else
    warning('Topup:Apply', ...
        'Cannot renumber file suffix as requested!');    
end

% Cleaning, if requested
if fl_clean 
    delete(fn_data_cord_gz)
    delete(fn_data_cord_nosf)
end

end