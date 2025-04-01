{
  description = "Jax devshell";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org" # Cached cuda packages.
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    cudaPackages = pkgs.cudaPackages_12_8;
    python = pkgs.python312;
    pythonPackages = pkgs.python312Packages;

    packages = [
      pkgs.just
      pkgs.uv
      python
      pythonPackages.venvShellHook
    ];

    libs = [
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib

      # Where your local "lib/libcuda.so" lives. If you're not on NixOS,
      # you should provide the right path (likely another one).
      "/run/opengl-driver"
    ];

    shell = pkgs.mkShell {
      name = "gnn-ranking";
      inherit packages;

      env = {
        CC = "${pkgs.gcc}/bin/gcc"; # For `torch.compile`.
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
      };

      venvDir = "./.venv";
      postShellHook = ''
        uv sync
        just device-check
      '';
    };
  in {
    devShells.${system}.default = shell;
  };
}
