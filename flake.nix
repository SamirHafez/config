{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations.pi = nixpkgs.lib.nixosSystem rec {
      system = "aarch64-linux";
      modules = [
        ./hardware/pi.nix
        ./modules/homebridge.nix
        ./modules/lazylibrarian.nix
        ./modules/calibre-server.nix
        ./pi.nix
      ];
      specialArgs = { inherit system; };
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hardware/t470.nix ./modules/shared.nix ./nixos.nix ];
      specialArgs = { inherit home-manager; };
    };
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./hardware/vm.nix
        ./modules/vmware-guest.nix
        ./modules/shared.nix
        ./vm.nix
      ];
      specialArgs = { inherit home-manager; };
    };
  };
}
