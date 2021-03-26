function fn_out = crc_rm_suffix(fn_in, regexp_filt)
% Remove trailing suffix to a filename based on a regexp expression.
% For example, to remove the '_01234' suffix from 3D image files obtaining 
% after splitting a 4D image file with spm_split, should use '_\d{5,5}$'
% as this picks the index of '_' followed by 5 digits at the end of the
% filename.
% Note that 
% - the function does NOT check the validity of the regexp passed
% - some/all the output filenames could be the same
% 
% INPUT
% fn_in         : (char/cell array of) filename(s) to consider
% regexp_filt   : recular expression to match, default '_\d{5,5}$'
% 
% OUTPUT
% fn_out        : (char/cell array of) filename(s) after removing the
%                  suffix, if found.
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

%% deal with input
if nargin<2
    regexp_filt = '_\d{5,5}$';
end

if iscell(fn_in) % check input type, char or cell
    flag_cell = true; % need to return a cell (array)
else
    flag_cell = false; % need to return a char (array)
end

% if char input, convert into cell array for ease of use
if ~flag_cell
    fn_inC = cellstr(fn_in);
else
    fn_inC = fn_in;
end

% Find out number of files to deal with and prepare cell output
Nfn = numel(fn_inC);
fn_outC = cell(size(fn_inC));

% Loop over all files and do the job
for ifn = 1:Nfn
    % split into filename parts
    [fn_pth,fn_nam,fn_ext,fn_num] = spm_fileparts(fn_inC{ifn});

    % find final that inclused '_' followed by 5 digits
    tt = regexp(fn_nam,regexp_filt);

    % remove it if possible
    if ~isempty(tt)
        fn_nam_cl = fn_nam(1:tt-1);
    else
        fn_nam_cl = fn_nam;
    end

    % rebuild output, without the matched part if possible
    if isempty(fn_num)
        fn_outC{ifn} = fullfile(fn_pth,[fn_nam_cl,fn_ext]);
    else
        fn_outC{ifn} = fullfile(fn_pth,[fn_nam_cl,fn_ext,fn_num]);
    end
end

% Deal with out, i.e. return same type of array
if ~flag_cell
    fn_out = char(fn_outC);
else
    fn_out = fn_outC;
end


end