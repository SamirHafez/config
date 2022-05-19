{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-locked-kernel.url =
      "github:nixos/nixpkgs/bacbfd713b4781a4a82c1f390f8fe21ae3b8b95b";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-locked-kernel";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-locked-kernel";
    };
  };

  outputs =
    { self, nixpkgs-locked-kernel, nixpkgs-unstable, home-manager, fenix }: {
      nixosConfigurations.pi = import ./pi/pi.nix {
        nixpkgs = nixpkgs-unstable;
      };
      nixosConfigurations.nixos = import ./nixos/nixos.nix {
        inherit home-manager fenix;
        nixpkgs = nixpkgs-locked-kernel;
      };
    };
}
