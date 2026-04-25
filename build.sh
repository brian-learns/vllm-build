#!/usr/bin/env bash
# build vllm versions
if [[ -n "$DEBUG" ]]; then 
  set -x
fi
# "strict mode"
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value

# work in the script's home directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # http://stackoverflow.com/questions/59895
cd "$DIR"

# check and process arguments
if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <vllm version tag to build>"
    echo "  look up versions at https://github.com/vllm-project/vllm/releases"
    exit 1
fi
version=$(basename "$1")
venv="vllm-${version}"
repo="https://github.com/vllm-project/vllm"
giturl="git+${repo}/@${version}"
echo "build vllm @ $version"
echo ""
echo "about to create virtual environment $DIR/$venv and install $giturl"
echo ""
read -r -p "Are you sure you want to proceed? [y/N] " confirm
if [[ "$confirm" != [yY]* ]]; then
    exit 1
fi

# build environment for DGX Spark
TRITON_PTXAS_PATH=$(which ptxas)
export TRITON_PTXAS_PATH                 # prevents build errors
export CUDA_HOME=/usr/local/cuda         # prevents build errors
export UV_TORCH_BACKEND=auto             # torch backend selection
export MAX_JOBS=4                        # limit CUDA compiler jobs when building wheels

uv venv "${venv}"

# shellcheck source=/dev/null
source "${venv}/bin/activate"

# PyTorch
#uv pip install torch torchvision torchaudio --torch-backend auto
#python -c "import torch; print(torch.accelerator.current_accelerator().type)"
# cuda

# build from source so it all compiles
time uv pip install "${giturl}"

echo "built, now testing..."
# test that it runs without any errors, and that torch looks configured
final_version=$(vllm -v)
torch_accelerator=$(python -c "import torch; print(torch.accelerator.current_accelerator().type)")

mkdir -p $DIR/requirements/
# get the requirements for easy duplication
uv pip freeze > "requirements/requirements.${version}.txt"

echo "✅ ${final_version} torch_accelerator: ${torch_accelerator}"
echo ">> initialize environment:"
echo "source ${DIR}/${venv}/bin/activate"
echo ">> launch llvm:"
echo "${DIR}/${venv}/bin/vllm"
