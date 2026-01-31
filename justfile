
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
