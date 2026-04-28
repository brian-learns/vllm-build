#!/usr/bin/env bash
#
# Build sglang on DGX Spark
#
REPO=https://github.com/sgl-project/sglang
PROJ=$(basename $REPO)

#
# bash boilerplate
#
DEBUG=DEBUG
[[ -n "$DEBUG" ]] && set -x   # debug mode
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
# work in the script's home directory
cd "$DIR"

#
# check and process user input
#
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <$PROJ version tag to build>"
    echo "  look up versions at $REPO/releases"
    exit 1
fi
version=$(basename "$1")
venv="${PROJ}-${version}"
giturl="git+${REPO}/@${version}#subdirectory=python"
echo "build $PROJ @ $version"
echo ""
echo "building ${giturl}"
echo " in $DIR/$venv"
echo ""

#
# Build
#

# build environment for DGX Spark
TRITON_PTXAS_PATH=$(which ptxas)
export TRITON_PTXAS_PATH                 # prevents build errors
export CUDA_HOME=/usr/local/cuda         # prevents build errors
export UV_TORCH_BACKEND=auto             # torch backend selection
export UV_VENV_RELOCATABLE="${UV_VENV_RELOCATABLE-1}"
export MAX_JOBS="${MAX_JOBS:-8}"         # limit CUDA compiler jobs when building wheels
export MAX_JOBS="16"         # limit CUDA compiler jobs when building wheels
export TORCH_CUDA_ARCH_LIST=12.1a
export UV_CACHE_DIR="$DIR"/uv-cache      # clear the local cache to force rebuild

# create and activate the virtual environment
uv venv "${venv}"
# shellcheck source=/dev/null
source "${venv}/bin/activate"

# build from source so it all compiles
uv pip install torch==2.9.1 torchvision torchaudio --torch-backend auto
uv pip install sglang-kernel --index-url https://sgl-project.github.io/whl/cu130/
uv pip install imageio diffusers addict cache_dit opencv-python trimesh scikit-learn
time uv pip install "${giturl}"
#
# test
#
echo "built, now testing..."
# test that it runs without any errors, and that torch looks configured
sglang version
sglang generate -h

echo ">> initialize environment:"
echo "source ${DIR}/${venv}/bin/activate"
echo ">> launch $PROJ:"
echo "${DIR}/${venv}/bin/$PROJ"
