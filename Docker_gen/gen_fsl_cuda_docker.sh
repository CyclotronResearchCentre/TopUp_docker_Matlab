# This file generates a fully fledged FSL docker image with a specified version using
# neurodocker (https://github.com/ReproNim/neurodocker).
#
# USAGE
#   ./gen_fsl_docker.sh [version] [date]
#
#   [version]   : A valid FSL version. The default is '6.0.3'
#
# DISCLAIMER
#   This image contains a full installation of FSL and, thus, is very heavy. This should
#   not be used as a final image but only serve as a base for binary specific images.

echo ""
echo "GENERATE DOCKER IMAGE FOR FSL ${FSL_VERSION}"
echo ""

# Exit directly if any command exit with non-zero status
set -e

# Set FSL version and date
FSL_DEFAULT_VERSION="6.0.3"
FSL_VERSION=${1:-${FSL_DEFAULT_VERSION}}
FSL_DATE=$(date +"%Y%m%d")
FSL_IMG="fsl:${FSL_VERSION}-cuda-${FSL_DATE}"

# If docker image already exists, exit
if [ $(docker images -q ${FSL_IMG}) ]; then
    echo "Docker image '${FSL_IMG}' already exists."
    echo ""
    echo "DONE!"
    echo ""

    exit 0
fi

# Work in a temporary directory to reduce docker build context
echo "Moving to temporary directory..."
SRC_DIR=$(pwd)
TMP_DIR="/tmp/fsl_docker"
mkdir -p ${TMP_DIR}
cd ${TMP_DIR}
echo "Moved to temporary directory '${TMP_DIR}'."

# Generate Dockerfile
echo "Generating Dockerfile..."
neurodocker generate docker \
    --base=nvidia/cuda:8.0-runtime \
    --pkg-manager=apt \
    --install openssl \
    --fsl \
        version="${FSL_VERSION}" \
        install_path="/fsl" \
        exclude_paths="doc refdoc man" \
    --run "mkdir -p /home/fsl" \
    --workdir "/home/fsl" \
    > Dockerfile
echo "Dockerfile generated at '${TMP_DIR}/Dockerfile'."

# Build docker image
echo "Building docker image (This may take a while)..."
docker build --rm --quiet -t ${FSL_IMG} .
echo "Docker image built with tag '${FSL_IMG}'."

# Clean temporary directory
echo "Cleaning temporary directory..."
cd ${SRC_DIR}
rm -rf ${TMP_DIR}

echo ""
echo "DONE!"
echo ""

exit 0
