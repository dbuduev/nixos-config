
format:
	@ alejandra *.nix
	@ alejandra home/*.nix

boot system="zenbook":
	@ sudo nixos-rebuild boot --flake .#{{system}}

switch system="zenbook":
	@ sudo nixos-rebuild switch --flake .#{{system}}

cleanup:
	@ sudo nix-collect-garbage --delete-older-than 3d

update:
	@ nix flake update && git add flake.lock && git ci -sm "flake update" 

upgrade:
	@ topgrade --only rustup

# Run Gemma 4 12B locally via llama.cpp (Vulkan/RADV on the Radeon 890M).
# Serves the chat UI + OpenAI-compatible API at http://localhost:8080
# ggml-org repo quants: Q4_K_M (7.4GB, default), Q8_0 (12.7GB), BF16 (23.8GB)
gemma quant="Q4_K_M" ctx="8192":
	@ llama-server -hf ggml-org/gemma-4-12B-it-GGUF:{{quant}} -ngl 99 -c {{ctx}}

# Same model using Google's quantization-aware-trained 4-bit GGUF — better
# quality than standard Q4 at ~the same size. Best pick for the 890M.
gemma-qat ctx="8192":
	@ llama-server -hf google/gemma-4-12B-it-qat-q4_0-gguf -ngl 99 -c {{ctx}}

vm-build:
	nixos-rebuild build-vm --flake .#devvm

vm-run:
	./result/bin/run-devvm-vm

vm-ssh:
	ssh -p 2222 dennisb@localhost
