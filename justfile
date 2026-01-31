
format:
	@ alejandra *.nix
	@ alejandra home/*.nix

boot:
	@ sudo nixos-rebuild boot --flake .#mb-vm

switch:
	@ sudo nixos-rebuild switch --flake .#mb-vm 

cleanup:
	@ sudo nix-collect-garbage --delete-older-than 3d

update:
	@ nix flake update && git add flake.lock && git ci -sm "flake update" 

upgrade:
	@ topgrade --only rustup
