{
  # Use `uv add jax[cuda12_local]` to install JAX in the venv.

  # Because of how NixOS works you can't install JAX with CUDA built by JAX
  # itself. Hence this flakes provides all the tiny little details to point JAX
  # to Nix's CUDA packages.

  description = "JAX devShell";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org" # Cached CUDA packages.
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
      name = "jax-devshell";
      inherit packages;

      env = {
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
        XLA_FLAGS = "--xla_gpu_cuda_data_dir=${cudaPackages.cudatoolkit}";
      };

      venvDir = "./.venv";
      postShellHook = ''
        uv sync
        export PATH="$PATH:${cudaPackages.cudatoolkit}/bin"  # Add ptxas to PATH.
        just tests
      '';
    };
  in {
    devShells.${system}.default = shell;
  };
}
