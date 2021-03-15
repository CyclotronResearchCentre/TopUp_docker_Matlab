# "TopUP Docker" for Matlab & SPM

Some explanations how to install, set up and use the proposed solution for the TopUp (TU) tool from FSL. 

This mostly applies for SPM/Matlab users working on SPM as, otherwise on a Linux or Mac system, FSL can be directly installed and used.



## Requirements & installation

The 2 key elements are the Docker software and the TopUp container. You can get 

1.  the "Docker Desktop" from [here](https://www.docker.com/products/docker-desktop) after installing, make sure it runs on your system. You can have it start at reboot time or launch it from the "Apps" menu when you need it.
2. the `topup_6.0.3_20210212.tar` container (~350MB) from this [Dox address]( https://dox.uliege.be/index.php/s/E1YLYwkARhEeiOj) (only at ULiege).

Then the TopUp container must loaded into Docker, via

- the GUI, by loading the container

- the command line:

  - open "Windows PowerShell"
  - type 

  ````
  docker load -i topup_6.0.3_20210212.tar
  ````

The TopUp image should be visible in the GUI or typing `docker images` in the command line, as

````
REPOSITORY   TAG              IMAGE ID       CREATED       SIZE
topup        6.0.3-20210212   a934e1e1e37b   4 weeks ago   347MB
````

Note that launching the "Docker Engine" can take close to 1 minute (depending on your system).

The Matlab function `crc_topup_checkinstall` will do a quick check of the Docker installation and availability of the TopUp image.



## Code description

Functions are split in 3 layers: law, medium & high level functions. Note that the low and medium level functions do NOT depend on SPM, while the high level functions do.

### "Low level" functions

`crc_fsl(cmd, twd)` calls the TopUp function from inside the docker. It only requires 2 input: the command to execute the path to the folder with all the data and parameter files.

### "Medium level" functions

- `crc_topup_estimate` is called to estimate the TU warps, using `crc_fsl`, from one set of 4D images.
  - The input consists in the full-path filenames of the required files: 4D images, parameter and config. If they are not all in the same folder,  the parameter and config files are copied next to the data.
  - The output are the estimated spline coefficients and field in Hz, the latter could be omitted. The prefixes are hard-coded as `TUsc_` and `TUfh_`.
- `crc_topup_apply`  is called to apply the TU warps, using `crc_fsl`, from one set of 4D images and the estimated TU spline coefficients
  - The input consists in the whole 4D set of images to correct, corresponding parameters, spline coefficients, plus a bunch of other parameters (parameters and output prefix). If all the files are not in the same folder as the images to correct, this is taken care of.
  - The output are the unwarped input images in a gzipped 4D image file, prefixed as requested.

###"High level" functions

- `crc_topup_WarpEstimate` estimates warps based based on a few 3D images acquired with opposite phase-encoding directions. It needs the appropriately corresponding acquisition parameter file too.
- `crc_topup_WarpApply` applies the estimated warps on a series of 3D images. The images must correspond to the 1st line of the acquisition parameter file.
- `crc_topup_wrapper` provides the full solution for a series of 3D images and a few images acquired with opposite phase-encoding directions: 
  1. estimate the "warps" with `crc_topup_WarpEstimate`
  2. perform the "Realign & Estimate" step with SPM
  3. apply the estimated "warps" on the realigned images



## Using the "high level" functions



