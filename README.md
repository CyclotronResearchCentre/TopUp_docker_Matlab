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

- Docker is lightweight and can be easily installed on any machine;
- the number-crunching tool, aka. TopUp container, can be directly assembled from the full FSL distribution into a not-too-heavy (~350MB) single image;
- Docker with its container TopUp image then become a simple "black-box" executable piece of code, which can be called from the command line or a Matlab script/function!

This is thus the plan here...

---

## Some resources

Things to keep track off:

- the [TopUp page](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup) on the FSL website.
- the docker-ized version of TopUp is now available in the ['docker' branch](https://gitlab.uliege.be/CyclotronResearchCentre/Methods/topup_docker/tree/docker) of the repo, prepared by MG. Moreover the size of the file has been minimized, see issue #2, to about 355MB instead of several TB!
- Matlab [`system` command](https://nl.mathworks.com/help/matlab/ref/system.html) to execute operating system command and return output.
- some code/script for the CRC are available [here](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/sandpit/run_spatial_preproc_topup_realign_applytopup.m) and [here](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/common/preproc_distcorr_topup_estimate.m). (Note this is on our [ULiege GitLab server](https://gitlab.uliege.be/)).

The "TopUp" tool is part of FSL, for which there exist a docker. Trouble is this is the 'full monty' and thus very heavy if one only needs TopUp... See issue #2 for a potential solution

### Tips & tricks

#### Docker & Windows
When installing Docker on a Windows machine it runs in the "Windows containers" mode but one can switch to "Linux containers" ([instructions here](https://docs.docker.com/docker-for-windows/#switch-between-windows-and-linux-containers)): right-click on the Docker icon and select "Switch to Linux containers...". This can take up to 1 minute.

#### Parameters

The tool works best on 4D gzipped NIfTI files and one need to provide 2 files:

- `acqparams`, filename of the [acquisition parameters input file](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/TopupUsersGuide#A--datain) for TopUp :arrow_right: where from? See [`spatial_preproc_main`](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/sandpit/spatial_preproc_main.m) function.
- `b02b0` filename of default file for TopUp :arrow_right: available in [Gitlab folder](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/common/b02b0.cnf). 

Note that the `b02b0.cnf` file, as available from  [Flywheel](https://github.com/flywheel-apps/fsl-topup/blob/master/b02b0.cnf) is exactly the same as the one recommended for the [CRC](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/common/b02b0.cnf).


The format for the `acqparams.txt` goes as follows

> a 4-column table, with as many lines as used for the TOPUP distortion parameters estimation (typically 2 volumes AP and 2 volumes PA). The order of the parameters must consistent with the order of the volumes in the 4D image assembled as input to TOPUP.
> Columns correspond to i,j,k (x,y,z) PE directions and Readout duration.

For example, first two volumes A>>P and last two volumes P>>A

| Dir x | Dir y | Dir  z | Readout duration (sec) | Comment |
| ----- | ----- | ------ | ---------------- | ------- |
| 0     | -1    | 0      | 0.035            | A-P |
| 0     | -1    | 0      | 0.035            | A-P |
| 0     | 1    | 0      | 0.035            | P-A |
| 0     | 1    | 0      | 0.035            | P-A |

#### Test data

Some test data are available in the ['TestData' branch](https://gitlab.uliege.be/CyclotronResearchCentre/Methods/topup_docker/tree/TestData) but the definition of the `Readout duration` parameter is not well defined. The value should be derived from some of the raw acquisition parameters, see issue #4.

#### Processing steps

The recommended(?) approach is "TopUp estimate" :arrow_right: "Realign & Reslice" :arrow_right: "apply TopUp", as in [`run_spatial_preproc_topup_realign_applytopup.m` function](https://gitlab.uliege.be/CyclotronResearchCentre/LocalResources/Pipelines/mri/EpiSpatPreproc/blob/master/sandpit/run_spatial_preproc_topup_realign_applytopup.m). For the "TopUp estimate", it looks like just 2 volumes in each direction AP/PA are needed.

