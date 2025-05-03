{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, fenix }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        target = "thumbv6m-none-eabi";
        toolchain = with fenix.packages.${system}; combine [
          minimal.cargo
          minimal.rustc
          targets.${target}.latest.rust-std
        ];
      in
      {
        devShells.default = with pkgs; mkShell {
          buildInputs = [
            cargo
            toolchain
            rustfmt
            pre-commit
            rustPackages.clippy
            rust-analyzer
            probe-rs-tools
            elf2uf2-rs
          ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          shellHook = "exec fish";
        };
      }
    );
}
