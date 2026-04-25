# vllm-build

I don't like using docker, so this is a script to build [vLLM](https://github.com/vllm-project/vllm) on my DGX Spark.

```
$ ./build.sh 
Usage: ./build.sh <vllm version tag to build>
  look up versions at https://github.com/vllm-project/vllm/releases
```

uses [`uv`](https://docs.astral.sh/uv/) to install a python virtual environment and the requested version of vLLM.

## tested with 

```
v0.19.0 ✅ 0.19.0+cu130 torch_accelerator: cuda
v0.19.1 ✅ 0.19.1+cu130 torch_accelerator: cuda
v0.20.0 ✅ 0.20.0 torch_accelerator: cuda
```

## `pip freeze`

`requirements.txt` format `pip freeze` for successfull builds in `/requirements/` folder

## other work

See https://github.com/vllm-project/vllm/issues/36821 for more DGX Spark vllm build scripts and docker images.
