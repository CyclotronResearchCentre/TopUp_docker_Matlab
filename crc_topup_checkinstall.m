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

% Get defaults
Dimg_name = crc_topup_get_defaults('Dimg_name');
Dimg_vers = crc_topup_get_defaults('Dimg_vers');

% Calling docker to see which image is available
[status, cmd_out] = system('docker images');
% if status is 1, then there is an issue

flag = ~status;
if status
    fprintf('\nThere was a problem with Docker.');
    fprintf('\n\tCheck that Docker is installer and running.');
    fprintf('\n\tHere is the error message collected:');
    fprintf('\n\t%s',cmd_out);
    fprintf('\n');
else
    S1 = regexp(cmd_out,Dimg_name,'once'); % check name
    S2 = regexp(cmd_out,Dimg_vers,'once'); % check version
    if isempty(S1)
        fprintf('\nThere was a problem.');
        fprintf('\n\tThe "%s" image is not available.',Dimg_name);
        fprintf('\n\tHere are the Docker images collected:');
        fprintf('\n%s',cmd_out);
        fprintf('\n');        
        flag = false;
    elseif isempty(S2)
        fprintf('\nThere was a problem.');
        fprintf('\n\tThe "%s" image is available but not with the expected Tag (%s).', ...
            Dimg_name, Dimg_vers);
        fprintf('\n\tHere are the Docker images collected:');
        fprintf('\n%s',cmd_out);
        fprintf('\n');        
        flag = false;
    else
        fprintf('\nInstallation of "%s" docker seems fine:',Dimg_name);
        fprintf('\n%s',cmd_out);
        fprintf('\n');        
    end
end

end