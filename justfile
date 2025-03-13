
format:
	@ alejandra *.nix

boot:
	@ sudo nixos-rebuild boot --flake .#my-nixos 
switch:
	@ sudo nixos-rebuild switch --flake .#my-nixos 
cleanup:
	sudo nix-collect-garbage
