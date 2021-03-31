function fn_out = crc_renumber_fn(fn_in,opt)
% Function to renumber filenames after some 4D->3D file splitting with 
% 'spm_split' function. Indeed 'spm_split' always adds a 5 digit index
% starting at 00001 but to keep numbering consistent across 3D series when 
% manipulating files, e.g. 4D->3D->removing dummies->4D-3D.
% 
% INPUT
% fn_in     : (char/cell array of) filename(s) to consider
% opt       : structure of options for the numbering
%   .start  : starting index
% 
% OUTPUT
% fn_out    : (char/cell array of) filename(s) after removing the
%              suffix, if found.
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

if nargin<2
    opt = struct('start',1);
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

% Get basename of series, without the 5 digit index
fn_in_noNr = crc_rm_suffix(fn_inC,'_\d{5,5}$');

% Loop over all files and put new 
for ifn = 1:Nfn
    % create target filename, with new 5 digit index 
    fn_tmp = spm_file( fn_in_noNr{ifn}, ...
        'suffix', sprintf('_%05d',opt.start+ifn-1) );
    movefile( fn_in{ifn}, fn_tmp);
end

% Deal with out, i.e. return same type of array
if ~flag_cell
    fn_out = char(fn_outC);
else
    fn_out = fn_outC;
end

end