# "TopUP Docker" for Matlab & SPM

Some explanations how to install, set up and use the proposed solution. 

This mostly applies for SPM/Matlab users working on SPM as, otherwise on a Linux or Max system, FSL can be directly installed and used.



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

The "topup" image should be visible in the GUI or typing `docker images` in the command line. Note that launching the "Docker Engine" can take close to 1 minute (depending on your system).

The Matlab function `crc_topup_checkinstall` will do a quick check of the Docker installation and availability of the "topup" image.

