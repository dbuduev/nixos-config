
format:
	@ alejandra *.nix

switch:
	@ sudo nixos-rebuild switch --flake .#my-nixos --option allow-dirty true
cleanup:
	sudo nix-collect-garbage
