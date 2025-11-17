
format:
	@ alejandra *.nix
	@ alejandra home/*.nix

boot:
	@ sudo nixos-rebuild boot --flake .#my-nixos 

switch:
	@ sudo nixos-rebuild switch --flake .#my-nixos 

cleanup:
	@ sudo nix-collect-garbage --delete-older-than 3d

fhs:
	#!/usr/bin/env bash
	set -euo pipefail
	pushd home/FHS
	nix develop .#default

update:
	@ nix flake update && git add flake.lock && git ci -sm "flake update" 

upgrade:
	@ topgrade --only rustup
