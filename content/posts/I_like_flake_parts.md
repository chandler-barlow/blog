---
title: "I like flake parts"
date: 2025-11-28T23:13:49Z
draft: false
---

I have been using flake parts for almost all of my projects recently. 
For those of you un-initiated, flake-parts provides a module system for flakes.
This ends up being a lot more nifty than you would assume on first blush, or well
it's more useful than I had assumed.  

# For haskell projects

Flake parts really simplifies all of the boiler plate involved with setting up new
haskell projects in the nix ecosystem. Traditionally starting a new haskell project
involved hand cranking a bunch of flake boiler plate and then hand wiring a package
definition.  

When using flake-parts it ends up looking like this.

```bash
nix flake init -t github:srid/haskell-flake
```

Which provides this nice flake

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem = { self', pkgs, ... }: {

        # Typically, you just want a single project named "default". But
        # multiple projects are also possible, each using different GHC version.
        haskellProjects.default = {
          # The base package set representing a specific GHC version.
          # By default, this is pkgs.haskellPackages.
          # You may also create your own. See https://community.flake.parts/haskell-flake/package-set
          # basePackages = pkgs.haskellPackages;

          # Extra package information. See https://community.flake.parts/haskell-flake/dependency
          #
          # Note that local packages are automatically included in `packages`
          # (defined by `defaults.packages` option).
          #
          packages = {
            # aeson.source = "1.5.0.0";      # Override aeson to a custom version from Hackage
            # shower.source = inputs.shower; # Override shower to a custom source path
          };
          settings = {
            #  aeson = {
            #    check = false;
            #  };
            #  relude = {
            #    haddock = false;
            #    broken = false;
            #  };
          };

          devShell = {
            # Enabled by default
            # enable = true;

            # Programs you want to make available in the shell.
            # Default programs can be disabled by setting to 'null'
            # tools = hp: { fourmolu = hp.fourmolu; ghcid = null; };

            # Check that haskell-language-server works
            # hlsCheck.enable = true; # Requires sandbox to be disabled
          };
        };

        # haskell-flake doesn't set the default package, but you can do it here.
        packages.default = self'.packages.example;
      };
    };
}
```

What's great about this is that you get

1. A fully configured project from one command
2. Nix app integration with your cabal exe's
3. The ability to override packages in the snapshot easily. Something that required quite a bit of work when using haskell.nix alone.

This really is all it takes. The nix application integration is also extremely useful.
For example if you have an exe in your `*.cabal` file called `my-exe` you can run it
via `nix run .#my-exe`.

This post wasn't really meant to be much of a tutorial, I just really like how simple flake-parts
makes working with flakes. The only downside I have noticed is that it can be a bit odd when 
trying to do anything out of the scope provided by the module writer. This is kind of par for the
course though when dealing with anything that simplifies/abstracts boilerplate. I find it an acceptable
trade off but ymmv.
