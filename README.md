# vllm-build

I don't like using docker, so this is a script to build vllm on my DGX Spark.

```
$ ./build.sh 
Usage: ./build.sh <vllm version tag to build>
  look up versions at https://github.com/vllm-project/vllm/releases
```

uses [`uv`](https://docs.astral.sh/uv/) to install a python virtual environment and the requested version of vLLM.


