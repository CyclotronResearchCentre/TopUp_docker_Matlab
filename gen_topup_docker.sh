# This file generates a minified FSL docker image to run topup and all the related
# binaries using neurodocker-minify (https://github.com/ReproNim/neurodocker).
#
# USAGE
#   ./gen_topup_docker.sh [version] [date]
#
# NOTE
#   The minification process is performed by pruning the '/opt' directory of the full
#   FSL image after the operations from the example[1] have been tracked.
#
#   [1] https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/ExampleTopupFollowedByApplytopup


# Exit directly if any command exit with non-zero status
set -e

# Get FSL version from command line or fallback to
FSL_DEFAULT_VERSION="6.0.3"
FSL_VERSION=${1:-${FSL_DEFAULT_VERSION}}
FSL_DATE=${2:-$(date +"%Y%m%d")}
FSL_IMG="fsl:${FSL_VERSION}-${FSL_DATE}"
FSL_CONTAINER="fsl-container"
TOPUP_IMG="topup:${FSL_VERSION}-${FSL_DATE}"
echo ""
echo "GENERATE DOCKER IMAGE FOR FSL TOPUP (FSL ${FSL_VERSION})"
echo ""

# Check if FSL docker image exists
if [ ! $(docker images -q "${FSL_IMG}") ]; then
    echo "FSL base image '${FSL_IMG}' not found on your system."
    echo ""
    echo "FAILED!"
    echo ""
    exit 1
fi

# Work in a temporary directory
echo "Creating temporary directory..."
SRC_DIR=$(pwd)
TMP_DIR="/tmp/topup_docker"
mkdir -p ${TMP_DIR}
echo "Temporary directory created."

# Copy data
echo "Copying test data to temporary directory..."
cp \
    data/fmap/sub-s011_ses-baseline_dir-PA_epi_4topup.nii \
    data/func/sub-s011_ses-baseline_task-AXcpt_bold_2topup.nii \
    data/acq_params.txt \
    data/b02b0.cnf \
    ${TMP_DIR}
echo "Test data copied."

# Move to temporary directory
echo "Moving to temporary directory..."
cd ${TMP_DIR}
echo "Moved to temporary directory '${TMP_DIR}'."

# Minify FSL image
echo "Minifying FSL image..."
docker run \
    --rm \
    -itd \
    -v $(pwd):/home/fsl \
    --name fsl-container \
    --security-opt=seccomp:unconfined \
    ${FSL_IMG}
cmd1="topup --imain=sub-s011_ses-baseline_dir-PA_epi_4topup --datain=acq_params.txt --config=b02b0.cnf --out=topup_results --verbose"
cmd2="applytopup --imain=sub-s011_ses-baseline_task-AXcpt_bold_2topup --inindex=1 --datain=acq_params.txt --topup=topup_results --method=jac --interp=spline --out=hifi_images --verbose"
printf "y\n" | neurodocker-minify \
    --container fsl-container \
    --dirs-to-prune /fsl \
    --commands "$cmd1" "$cmd2"
echo "Minification finished."

# Store resulting image
echo "Saving minified image..."
docker export fsl-container | docker import - topup:tmp
docker stop fsl-container
echo "Minified image saved as 'topup:tmp'."

# Finalize image
echo "Finalizing TopUp image..."
cat <<EOT >> Dockerfile
FROM topup:tmp
WORKDIR /home/fsl
RUN ln -s /fsl/bin/topup /usr/local/bin/topup \
    && ln -s /fsl/bin/applytopup /usr/local/bin/applytopup
ENV FSLDIR="/fsl" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/fsl/bin/fsltclsh" \
    FSLWISH="/fsl/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q"
EOT
docker build --rm -t ${TOPUP_IMG} -< Dockerfile
echo "TopUp image finalized."

# Clean temporary directory
echo "Cleaning temporary directory..."
cd ${SRC_DIR}
rm -rf ${TMP_DIR}

echo ""
echo "DONE!"
echo ""

exit 0


# TODO: Use docker-slim https://github.com/docker-slim/docker-slim
# Minify docker image: https://medium.com/better-programming/super-slim-docker-containers-fdaddc47e560
