function [flag, cmd_out] = crc_topup_checkinstall
% Function to check if 
% - the Docker app is running, and
% - the container image is loaded and available
% 
% OUTPUT
% flag      : 1, if all fine; 0, otherwise
% cmd_out   : message coming from the Docker
%__________________________________________________________________________
% Copyright (C) 2021 Cyclotron Research Centre

% Written by C. Phillips, 2021.
% GIGA Institute, University of Liege, Belgium

% Calling docker to see which image is available
[status, cmd_out] = system('docker images');
% if status is 1, then there is an issue

flag = ~status;
if status
    fprintf('\nThere was a problem.');
    fprintf('\n\tHere is the error message collected:');
    fprintf('\n\t%s',cmd_out);
    fprintf('\n');
else
    S = regexp(cmd_out,'topup','once');
    if ~isempty(S)
        fprintf('\nThere was a problem.');
        fprintf('\n\tThe "topup" image is not available.');
        fprintf('\n\tHere is the error message collected:');
        fprintf('\n%s',cmd_out);
        fprintf('\n');        
        flag = false;
    else
        fprintf('\nInstallation of "topup" docker seems fine.');
        fprintf('\n');        
    end
end

end