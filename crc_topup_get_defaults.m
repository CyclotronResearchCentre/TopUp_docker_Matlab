function varargout = crc_topup_get_defaults(defstr, varargin)
% Get/set the defaults values associated with an identifier
% FORMAT TUdef = crc_topup_get_defaults
% Return the global "defaults" variable defined in crc_topup_defaults.m.
%
% FORMAT defval = crc_topup_get_defaults(defstr)
% Return the defaults value associated with identifier "defstr".
% Currently, this is a '.' subscript reference into the global
% "TUdef" variable defined in crc_topup_defaults.m.
%
% FORMAT crc_topup_get_defaults(defstr, defval)
% Sets the defaults value associated with identifier "defstr". The new
% defaults value applies immediately to:
% * new modules in batch jobs
% * modules in batch jobs that have not been saved yet
% This value will not be saved for future sessions of TopUp. To make
% persistent changes, change crc_topup_defaults.m
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium
% 
% but actually copy-pasted from SPM, then updated.

% Global variable for structure with TopUp defaults
global TUdef
if isempty(TUdef)
    crc_topup_defaults;
end

if nargin == 0
    varargout{1} = TUdef;
    return
end

try
    % Assume it's working as standard SPM functionality
    % construct subscript reference struct from dot delimited tag string
    tags = textscan(defstr,'%s', 'delimiter','.');
    subs = struct('type','.','subs',tags{1}');
    
    if nargin == 1
        varargout{1} = subsref(TUdef, subs);
    else
        TUdef = subsasgn(TUdef, subs, varargin{1});
    end
catch %#ok<CTCH>
    varargout{1} = [];
    fprintf(1,'WARNING: no default value defined for %s!\n', defstr);
end

end