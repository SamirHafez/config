{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    #nixpkgs-locked-kernel.url = "github:nixos/nixpkgs/bacbfd713b4781a4a82c1f390f8fe21ae3b8b95b";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, fenix }: {
      nixosConfigurations.pi = import ./pi/pi.nix {
	inherit nixpkgs;
      };
      nixosConfigurations.nixos = import ./nixos/nixos.nix {
        inherit nixpkgs home-manager fenix;
      };
      nixosConfigurations.nixos-vm = import ./nixos/nixos-vm.nix {
        inherit nixpkgs home-manager fenix;
      };
    };
}
