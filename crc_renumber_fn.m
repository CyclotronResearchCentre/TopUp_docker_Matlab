function fn_out = crc_renumber_fn(fn_in,opt)
% Function to renumber filenames after some 4D->3D file splitting with
% 'spm_split' function. Indeed 'spm_split' always adds a 5 digit index
% starting at 00001 but to keep numbering consistent across 3D series when
% manipulating files, e.g. 4D->3D->removing dummies->4D-3D.
%
% INPUT
% fn_in      : (char/cell array of) filename(s) to consider
% opt        : structure of options for the numbering
%   .idshift : index shift can be >0 or >0, e.g.
%               -5 means [6 7 8...] becomes [1 2 3...], and
%                6 means [1 2 3...] becomes [7 8 9...]
%
% OUTPUT
% fn_out     : (char/cell array of) filename(s) after removing the
%               suffix, if found.
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

if nargin<2
    opt = struct('idshift',0);
end

if opt.idshift==0
    fn_out = fn_in;
    fprintf('NOTHING to do here as shift=0 !');
else
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
    [fn_in_noNr,sf_index] = crc_rm_suffix(fn_inC,'_\d{5,5}$');
    
    % Extract indexes and sort in ascending order, "just in case"
    sf_index_ch = char(sf_index);
    ind_fn = str2num(sf_index_ch(:,2:end)); %#ok<*ST2NM>
    [ind_fn, li_ind_fn] = sort(ind_fn);
    
    % Loop over all files and put new index
    if opt.idshift<0 % shift backward, so use increasing order
        for ifn = 1:Nfn
            % create target filename, with new 5 digit index
            fn_outC{ifn} = spm_file( fn_in_noNr{li_ind_fn(ifn)}, ...
                'suffix', sprintf('_%05d',opt.idshift + ind_fn(ifn)) );
            movefile( fn_inC{li_ind_fn(ifn)}, fn_outC{ifn});
        end
    elseif opt.idshift>0 % shift forward, so use decreasing order
        for ifn = Nfn:-1:1
            % create target filename, with new 5 digit index
            fn_outC{ifn} = spm_file( fn_in_noNr{li_ind_fn(ifn)}, ...
                'suffix', sprintf('_%05d',opt.idshift + ind_fn(ifn)) );
            movefile( fn_inC{li_ind_fn(ifn)}, fn_outC{ifn});
        end
    end
    % Deal with output, i.e. return same type of array
    if ~flag_cell
        fn_out = char(fn_outC);
    else
        fn_out = fn_outC;
    end
end
end