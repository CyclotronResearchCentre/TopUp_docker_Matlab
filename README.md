# TopUp Docker

Main idea: 
> **How to use TopUp correction with Docker, ideally called directly from Matlab?**

## Current situation

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

## Some resources

Things to keep track off:

- the [TopUp page](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup) on the FSL website;
- [Docker](https://hub.docker.com/) host a FSL-topup container [here](https://hub.docker.com/r/flywheel/fsl-topup). It looks like it was put there by [FlyWheel](https://flywheel.io/) people but it doesn't matter