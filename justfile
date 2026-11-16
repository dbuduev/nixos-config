
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

# Runs as a transient systemd user unit, so there is no QEMU window and no
# terminal to keep open. Use vm-run when you need the graphical console.
# Stop it from inside the guest (`sudo poweroff`); stopping the unit kills
# QEMU without a guest shutdown.
#
# Start devvm in the background (no window, no terminal)
vm-start:
	-@ systemctl --user reset-failed devvm 2>/dev/null
	systemd-run --user --unit=devvm \
	  --working-directory={{justfile_directory()}} \
	  --setenv=QEMU_OPTS="-display none" \
	  {{justfile_directory()}}/result/bin/run-devvm-vm

# Show devvm's unit state, or its last log lines once the unit is gone
vm-status:
	@ systemctl --user --no-pager status devvm || journalctl --user -u devvm -n 20 --no-pager

vm-ssh:
	ssh -p 2222 dennisb@localhost
