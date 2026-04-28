vllm serve "Qwen/Qwen3.6-35B-A3B-FP8" \
	--load-format fastsafetensors \
	--gpu-memory-utilization 0.5 \
	--fail-on-environ-validation \
	--enable-prompt-tokens-details
