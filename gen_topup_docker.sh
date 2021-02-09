# This file generates a minified FSL docker image to run topup and all the related
# binaries using neurodocker-minify (https://github.com/ReproNim/neurodocker).
#
# USAGE
#   ./gen_topup_docker.sh [version]
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
TOPUP_IMG="topup:${FSL_VERSION}-${FSL_DATE}-test"
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
echo "Moving to temporary directory..."
SRC_DIR=$(pwd)
TMP_DIR="/tmp/topup_docker"
mkdir -p ${TMP_DIR}
cd ${TMP_DIR}
echo "Moved to temporary directory '${TMP_DIR}'."

# Follow the instructions from https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/ExampleTopupFollowedByApplytopup
EXEC_FILE="run.sh"
cat <<EOT >> ${EXEC_FILE}
fslroi blip_up b0_blip_up 0 1
fslroi blip_down b0_blip_down 0 1
fslmerge -t both_b0 b0_blip_up b0_blip_down
topup --imain=both_b0 --datain=acq_params.txt --config=b02b0.cnf --out=topup_results
applytopup --imain=blip_up,blip_down --inindex=1,2 --datatin=acq_params.txt --topup=topup_results --out=my_hifi_images
EOT
chmod a+x ${EXEC_FILE}

# Minify docker image
docker-slim build --target ${FSL_IMG} --tag ${TOPUP_IMG} --http-probe=false --exec-file ${EXEC_FILE}

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
