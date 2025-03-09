
format:
	@ alejandra *.nix

switch:
	@ sudo nixos-rebuild switch --flake .#my-nixos 
cleanup:
	sudo nix-collect-garbage
