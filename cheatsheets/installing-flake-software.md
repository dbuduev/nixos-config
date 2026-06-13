# Installing Flake-Distributed Software — Cheatsheet

How to add software to this config, from least to most ceremony. Grounded in
*this* repo (`flake.nix`, `home/home.nix`, `home/coder.nix`,
`hosts/*/configuration.nix`).

**Legend:** ★ = the claude-code pattern we already use · ⚠ = gotcha

> **Rule of thumb:** reach for the lowest-numbered option that works. Most
> software is option 1. Only ship the full claude-code treatment (option 3 +
> binary cache) when a flake actually gives you an overlay *and* a cache.

## Mental model

- A package ends up in a profile via `home.packages` (per-user, home-manager)
  or `environment.systemPackages` (system-wide). Where it *comes from* is the
  only thing that changes between options below.
- `pkgs` = nixpkgs 25.11. `unstable-pkgs` = nixpkgs-unstable, threaded in via
  `specialArgs`/`extraSpecialArgs` in `flake.nix`. Use unstable only when you
  need a newer version than 25.11 ships.
- A flake `input` is a pinned external source (recorded in `flake.lock`). What
  you *consume* from it is either a `packages.<system>.<name>` output or an
  `overlays.<name>`.

---

## Option 1 — It's in nixpkgs (the default)

No `flake.nix` changes. Check first:

```bash
nix search nixpkgs <name>
```

Then add the name:

```nix
# home/home.nix  (or coder.nix)
home.packages = with pkgs; [ ripgrep ];

# need a newer version than 25.11?
home.packages = [ unstable-pkgs.zig ];
```

Most things live here. Stop here unless the tool genuinely isn't packaged.

---

## Option 2 — Flake exposes a package output

The common third-party case: a flake whose `packages.<system>.default` is the
tool. Two edits.

**1. Add the input** (`flake.nix`):

```nix
inputs.someTool.url = "github:author/some-tool";
```

**2. Reference the output** at the call site:

```nix
home.packages = [ inputs.someTool.packages.${pkgs.system}.default ];
```

⚠ **`inputs` must be in scope.** Right now `flake.nix` threads `unstable-pkgs`
and `isHeadless` through `specialArgs`/`extraSpecialArgs` but **not `inputs`**.
To use option 2 cleanly, add `inherit inputs;` to both `specialArgs` and
`home-manager.extraSpecialArgs` in `mkSystem` once — then every future flake
tool is a one-liner. Until then you'd be plumbing each input through by hand.

⚠ Some flakes name the output something other than `default` (e.g.
`packages.${system}.someTool`). Check with:

```bash
nix flake show github:author/some-tool
```

---

## Option 3 ★ — Flake ships an overlay (the claude-code pattern)

When a flake publishes `overlays.default`, fold it into a pkgs set so the
package appears as a plain attribute (`pkgs.foo` / `unstable-pkgs.foo`) — nicer
at every call site, worth it when you reference the tool in several places.

This is exactly what we do for claude-code:

```nix
# flake.nix — input
claude-code.url = "github:sadjow/claude-code-nix";

# flake.nix — fold the overlay into unstable-pkgs
unstable-pkgs = import nixpkgs-unstable {
  inherit system;
  config.allowUnfree = true;
  overlays = [ claude-code.overlays.default ];
};
```

```nix
# home/coder.nix — now it's just an attribute
home.packages = [ unstable-pkgs.claude-code ];
```

To apply an overlay to the **stable** `pkgs` instead, set it on the nixpkgs
module via `nixpkgs.overlays = [ foo.overlays.default ];` in a host config (or
re-`import nixpkgs` the way `unstable-pkgs` is built).

---

## Binary cache (orthogonal — speeds up, doesn't install)

Separate from *how* you reference a package: a substituter lets you **download
prebuilt binaries** instead of compiling locally. Not needed for most tools;
add only when the flake publishes a cache. claude-code does
(`hosts/*/configuration.nix`):

```nix
nix.settings = {
  substituters       = [ "https://claude-code.cachix.org" ];
  trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
};
```

⚠ Without the matching `trusted-public-keys` entry, the substituter is ignored
and you build from source anyway.

---

## Decision table

| Situation | Do this |
|---|---|
| Package is in nixpkgs | Option 1 — add the name |
| Need a newer version than 25.11 | Option 1 with `unstable-pkgs.<name>` |
| Flake with a plain package output | Option 2 — input + `inputs.x.packages.${system}.default` |
| Flake ships an overlay, used in several places | Option 3 ★ — input + overlay, reference as `pkgs.<name>` |
| Flake publishes a binary cache | Add substituter + public key (any option above) |

## After any change

```bash
just format                 # alejandra
just switch system=zenbook  # rebuild + switch (or system=mb-vm / devvm)
just update                 # bump flake.lock inputs + commit
```
