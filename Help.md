# "TopUP Docker" for Matlab & SPM

Here are some explanations how to

- install and set up the "TopUp Docker" toolbox
- use the proposed solution in combination with SPM and the `matlabbatch` system

Note that this mostly applies for SPM/Matlab users working on SPM as, otherwise on a Linux or Mac system, FSL can be directly installed and used.

---

## Requirements & installation

The "TopUP Docker" toolbox relies on a "dockerized" version of the Top Up tool from FSL and some Matlab code. Here is how to install all these.

### Docker & TopUp container

The 2 key elements are the Docker software and the TopUp image itself.

1. You get:
   - the "Docker Desktop" from [here](https://www.docker.com/products/docker-desktop) . After downloading and installing the application, make sure it runs on your system. Note that you can have it start at reboot time or manually launch it from the "Apps" menu only when you need it.
   - the `topup_6.0.3_20210212.tar` container (~350MB) from this [Dox address]( https://dox.uliege.be/index.php/s/E1YLYwkARhEeiOj) (only at ULiege).

2. Then the TopUp container must be loaded into Docker, via the command line:

   - open "Windows PowerShell" from Windows "Apps" menu;
   - then, following [the manual](https://docs.docker.com/engine/reference/commandline/image_load/), type this command

   ````
   docker load -i topup_6.0.3_20210212.tar
   ````

The TopUp image should be visible in the GUI or by typing `docker images` in the command line, as

````
REPOSITORY   TAG              IMAGE ID       CREATED       SIZE
topup        6.0.3-20210212   a934e1e1e37b   4 weeks ago   347MB
````

Be aware that launching the "Docker Engine" can take close to 1 minute (depending on your system).

### Matlab code

The Matlab code should preferably be cloned from the host repository (XYX or your own fork) but can also be directly downloaded as a zip file. Then

- place the code in a folder such as `C:\My_code\TopUpDocker`;

- add this folder to Matlab path with this command at the prompt
  ````
  > addpath('C:\My_code\TopUpDocker')
  ````
  (one can also use the `pathtool` GUI to manage the path)
  
- in SPM's toolbox folder, such as `C:\My_code\SPM12\toolbox`, create a folder named `TopUpDocker`, i.e. `C:\My_code\SPM12\toolbox\TopUpDocker`;

- copy the function `tbx_cfg_TopUpDocker_redirect.m` from `C:\My_code\TopUpDocker` into `C:\My_code\SPM12\toolbox\TopUpDocker`

Now when launching SPM, then its "Batch" interface the `TopUp Docker Tools` entry should appear in the pull-down menu `SPM` :arrow_right:`Tools`.

Finally the Matlab function `crc_topup_checkinstall` will do a quick check of the Docker installation and availability of the TopUp image, returning some information, 

- whether the Docker is installed and running;
- whether the "TopUp" image is available; 
- whether it is the expected version (as defined in the "defaults") of the "TopUp" image;
- or everything seems fine.

---
## Matlab code description

Functions are split in 3 layers: law, medium & high level functions. Note that the low and medium level functions do NOT depend on SPM, while the high level functions do.

### "Low level" function

The  function `crc_fsl` calls the TopUp function inside the Docker. Using the function only requires 2 input and an optional 3rd one, all being `chars`: 

- `cmd`, the command to execute with all flags and input;
- `twd`, the path to the folder with all the data and parameter files;
- `onm`, the label of the operation for the shell script to be written out.

The output will be

- a `status` indicating if the call was successful or not;
- a `cmd_out` message from the Docker, possibly indicating the source of the problem (typically with the input formatting);
- a shell script file named `crc_topup_<operation>.sh` when a `onm` is passed as 3rd input

### "Medium level" functions

These functions can be used independently in other tools as they are not relying on SPM functions.

- `crc_topup_estimate` is called to estimate the TU warps, using `crc_fsl`, from one set of 4D images.
  - The input consists in the full-path filenames of the required files: 
    - 4D images, including images with both phase encoding directions **and** matching what is defined in the parameter file;
    - parameter and config files. If these are not all in the same folder,  the parameter and config files are copied next to the data.
  - The output are the estimated spline coefficients and field in Hz, the latter could be omitted. The prefixes are hard-coded as `TUsc_` and `TUfh_`.
- `crc_topup_apply`  is called to apply the TU warps, using `crc_fsl`, from one set of 4D images and the estimated TU spline coefficients
  - The input consists in the whole 4D set of images to correct, corresponding parameters, spline coefficients, plus a bunch of other parameters (parameters and output prefix). If all the files are not in the same folder as the images to correct, this is taken care of.
  - The output are the unwarped input images in a gzipped 4D image file, prefixed as requested.

###"High level" functions

These function rely on SPM for some data handling routines.

- `crc_topup_WarpEstimate` estimates warps based based on a few 3D images acquired with opposite phase-encoding directions. It needs the appropriately corresponding acquisition parameter file too.
- `crc_topup_WarpApply` applies the estimated warps on a series of 3D images. The images must correspond to the 1st line of the acquisition parameter file.
- `crc_topup_Wrapper` provides the full solution for a series of 3D functional MR images and a few images acquired with opposite phase-encoding directions, or multiple sessions of these: 
  1. estimate the "warps" with `crc_topup_WarpEstimate`, once for each individual session;
  2. perform the "Realign & Estimate" step with SPM, for all the sessions together (as usual in SPM) and returning a single "mean" image;
  3. apply the estimated "warps" on the realigned images, once for each session + the "mean" image.

For what purpose should these be used:

- the `crc_topup_WarpEstimate` and `crc_topup_WarpApply` functions could be used to correct other images, e.g. diffusion-weighted MRI. Some intermediate processing between the estimation and application steps should certainly be inserted;
- the `crc_topup_Wrapper` function is really tailored to take care of (multiple) session(s) of fMRI data.

## Using the "high level" functions

For ease of use the `crc_topup_Wrapper` function has been interfaced in the `matlabbatch` system. One can thus perform the TopUp "realign & unwarp" for one or multiple sessions. A few points to keep in mind as they are hard coded:

- the same parameter and config files will be used for all sessions;
- the same number of files from the `func` and `fmap` (inverted blip) acquisition will be used for all the sessions
- one `rp_*.txt` realignment parameter file per session will be created, and a single `ur_mean_*.nii`  image for all the sessions.

---
## NOTES

While the input data are in `int16` format, the images obtained after the TopUp correction are in `float32` format! Not sure if such a resolution is necessary and, moreover this could have some impact on how implicit masking is handled in SPM: zero is a valid value in `float32` but masked out in `int16`.