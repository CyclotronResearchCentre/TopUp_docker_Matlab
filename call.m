clear all; close all; clc;

%% Docker attributes
setenv("DOCKER_EXEC", "docker");            % The command to run docker.
setenv("FSL_IMG", "topup:6.0.3-20210212");  % The name of the topup image.

%% Run topup
%[status, cmd_out] = fsl("pwd", ["gen_fsl_docker.sh", "gen_topup_docker.sh"], ["*"]);
% fsl_topup("data/fmap/sub-s011_ses-baseline_dir-PA_epi_4topup.nii", ...
%           "data/acq_params.txt", ...
%           "data/b02b0.cnf", ...
%           "topup_results");

fsl_applytopup("data/func/sub-s011_ses-baseline_task-AXcpt_bold_2topup.nii", ...
          "1", ...
          "data/acq_params.txt", ...
          "topup_results", ...
          "jac", ...
          "spline", ...
          "hifi_images");


%% Define FSL function
% Call FSL from inside a docker image.
% Parameters
%   cmd (string) : The command to run inside the docker.
%   in_files (list[string]) : A list of the input files required by the
%       command.
%   out_patterns (list[string]) : A list of patterns matching all the
%       output files of the command that must be saved.
% Returns
%   status (int) : The exit code of the call.
%   cmd_out (string) : The stdout of the call.
% Notes
%   This function requires the 'DOCKER_EXEC' and 'FSL_IMG' environment
%   variables to be defined.
%   This function works in a temporary directory and copies all the
%   required input files into that directory.
function [status, cmd_out] = fsl(cmd, in_files, out_patterns)
    % Create temporary directory
    cwd = pwd;
    twd = tempname(tempdir);
    err = mkdir(twd);
    if err ~= 1
        status = 0;
        cmd_out = "Unable to create temporary directory";
        return
    end
    % Copy all the input files
    for i = 1 : length(in_files)
        copyfile(in_files(i), twd);
    end
    % Move to temporary directory
    cd(twd);
    % Run the FSL command
    docker_exec = getenv("DOCKER_EXEC");
    fsl_img = getenv("FSL_IMG");
    docker_cmd = join([docker_exec, "run", "--rm", "-v", strcat(twd, ":", "/home/fsl"), fsl_img]);
    [status, cmd_out] = system(join([docker_cmd, cmd]), "-echo");
    % Copy all the output files to the initial directory
    for i = 1 : length(out_patterns)
        movefile(out_patterns(i), cwd);
    end
    % Clean temporary directory and go back to initial directory
    delete("*");
    cd(cwd);
    rmdir(twd);
    isfolder(twd)
end


function [status, cmd_out] = fsl_topup(imain, datain, config, out)
    in_files = [imain, datain, config];
    [filepath, imain_name, ext] = fileparts(imain);
    [filepath, datain_name, datain_ext] = fileparts(datain);
    [filepath, config_name, config_ext] = fileparts(config);
    cmd = join(["topup", ...
                strcat("--imain=", imain_name), ...
                strcat("--datain=", datain_name, datain_ext), ...
                strcat("--config=", config_name, config_ext), ...
                strcat("--out=", out), ...
                "--verbose"]);
    [status, cmd_out] = fsl(cmd, in_files, strcat(out, "*"));
end

function [status, cmd_out] = fsl_applytopup(imain, inindex, datain, topup, method, interp, out)
    in_files = [imain, datain];
    topup_res = dir(strcat(topup, "*"));
    for i = 1:length(topup_res)
        in_files = [in_files, fullfile(topup_res(i).folder, topup_res(i).name)];
    end
    [filepath, imain_name, ext] = fileparts(imain);
    [filepath, datain_name, datain_ext] = fileparts(datain);
    [filepath, topup_name, ext] = fileparts(topup);
    cmd = join(["applytopup", ...
                strcat("--imain=", imain_name), ...
                strcat("--inindex=", inindex), ...
                strcat("--datain=", datain_name, datain_ext), ...
                strcat("--topup=", topup_name), ...
                strcat("--method=", method), ...
                strcat("--interp=", interp), ...
                strcat("--out=", out), ...
                "--verbose"]);
    [status, cmd_out] = fsl(cmd, in_files, strcat(out, "*"));
end