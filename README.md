# devin-cli-overlay

Nix flake for [Devin CLI](https://cli.devin.ai). Pre-built binaries, auto-updated every 6 hours.

## Usage

### Flake input

```nix
{
  inputs.devin-cli-overlay = {
    url = "github:charliemeyer2000/devin-cli-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Add the overlay:

```nix
nixpkgs.overlays = [devin-cli-overlay.overlays.default];

# Then use pkgs.devin-cli in your packages
```

Or reference directly:

```nix
devin-cli-overlay.packages.${system}.devin
```

### Try without installing

```bash
nix run github:charliemeyer2000/devin-cli-overlay
```

### Pin a version

```nix
devin-cli-overlay.packages.${system}."2026.3.20-7"
```

## How it works

`versions/*.json` files contain URLs and SHA256 hashes pointing to Devin's CDN. No binaries stored in git. `nix build` fetches and verifies at build time. GitHub Actions checks for new releases every 6 hours.

## Platforms

aarch64-darwin, x86_64-darwin, aarch64-linux, x86_64-linux

## License

Nix packaging: MIT. Devin CLI binary: proprietary (Cognition AI).
