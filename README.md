# TopUp Docker

Main idea: 
> **How to use TopUp correction with Docker, ideally called directly from Matlab?**

## Context

We need to correct for functional MRI image deformation due to field inhomogeneities. There are different ways to do it, the main 2 are

- "fieldmap". The idea is to directly measure the fieldmap with some specific data:

  - before/after acquiring the functional data, acquire specific "fieldmap" images, typically amplitude and phase from 2 different echo times; 
  - estimate the field inhomogeneities from these and calculate a "voxel displacement map" (VDM);
  - apply this VDM to the functional data, which can be combined with the realignment procedure with SPM's `Realign & Unwarp` module.
- "TopUp". The idea is to acquire data with an opposite encoding direction.
  - before/after acquiring the functional data, acquire some more functional volume in the opposite phase encoding direction; e.g. one set in the anterior-posterior (AP) direction and the other in the posterior-anterior (PA) direction;
  - combining the deformation from the AP- and PA-direction data allows the estimation of the inhomogeneity induced deformation, i.e.  a "voxel displacement map" (VDM);
  - apply this VDM to the functional data, this is done *after* performing a standard (rigid-body) realignment of the fMRI series.

It appears that the "TopUp" approach is more efficient than the "fieldmap" one (need some reference here!). Unfortunately the "TopUp" approach only exists as an [FSL tool](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL), i.e. it only runs on a Linux (or Mac) OS and is not quite Matlab compatible.

## Current situation

In order to apply a "TopUp" correction, one thus need to run it on a (virtual) machine with FSL installed. Since we are used to work with Matlab, this one is also installed and the whole process is scripted in Matlab, i.e. the TopUp executable is called directly from within Matlab...

There is one main drawback to this way of working: one need a full installation of FSL, Matlab, and SPM on his/her machine. So everything has been installed in a virtual machine. Then again, this means one has to switch from his machine OS (usually Windows) to a virtual Linux box, and given the specificity of the processing there is a good risk that  data get messed up when switching from one to the other and back.

Can we de better? Yes, probably : 

- Docker is lightweight and can be easily installed on any machine
- the number-crunching tool, aka. container, can be directly and easily downloaded from DockerHub
- Docker with its container then become a simple "black-box" executable piece of code, which can be called from the command line or a Matlab script/function!

This is thus the plan here...

## Some resources

Things to keep track off:

- the [TopUp page](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup) on the FSL website.
- [Docker](https://hub.docker.com/) host a FSL-topup container [here](https://hub.docker.com/r/flywheel/fsl-topup). It looks like it was put there by [FlyWheel](https://flywheel.io/) people but it doesn't matter.
- Matlab [`system` command](https://nl.mathworks.com/help/matlab/ref/system.html) to execute operating system command and return output.
- some code/script for the CRC are available [here](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/sandpit/run_spatial_preproc_topup_realign_applytopup.m) and [here](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/common/preproc_distcorr_topup_estimate.m). (Note this is on our [ULiege GitLab server](https://gitlab.uliege.be/)).

