# angzarr-prj-log: development commands.
#
# Container overlay pattern: this file runs on the host and delegates into the
# org's pinned Rust toolchain image, with `justfile.container` mounted over
# `justfile` there; DEVCONTAINER=true runs the recipes in place. CI runs
# `just -f justfile.container <recipe>` on its own toolchain.
set shell := ["bash", "-c"]

# Submodule-protection and secret-scanning recipes (install-submodule-hooks,
# check-submodules-clean, scan-secrets). Source of truth:
# angzarr-project/submodule.just.
import? 'angzarr-project/submodule.just'

TOP := justfile_directory()
# Pinned org Rust toolchain image (tag and digest); override with
# ANGZARR_RUST_IMAGE.
RUST_IMAGE := env_var_or_default("ANGZARR_RUST_IMAGE", "ghcr.io/angzarr-io/angzarr-rust:9e07ae0@sha256:1f70b5de243d50aab989103ce87be393b6282c538ecabccef5f07c15760ac156")
# Rootless docker maps container uid 0 to the host user, so `-u 0:0` makes
# bind-mounted writes (target/, .cargo-container/) land as the host user.
# Rootful docker runs as the host uid.
CONTAINER_USER_ARG := if `docker info 2>/dev/null | grep -q rootless && echo yes || echo no` == "yes" { "-u 0:0" } else { "-u $(id -u):$(id -g)" }

default:
    @just --list

# Delegate a container-side recipe: run in place inside a devcontainer,
# otherwise in the pinned image with justfile.container overlaid as justfile.
[private]
_container +ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "${DEVCONTAINER:-}" = "true" ]; then
        just --justfile "{{TOP}}/justfile.container" {{ARGS}}
    else
        docker run --rm {{CONTAINER_USER_ARG}} --network=host \
            -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
            -v "{{TOP}}:/workspace:Z" \
            -v "{{TOP}}/justfile.container:/workspace/justfile:ro" \
            -w /workspace \
            -e CARGO_HOME=/workspace/.cargo-container \
            "{{RUST_IMAGE}}" just {{ARGS}}
    fi

# Architecture lint: module-level layer rules (archlint.toml)
archlint: (_container "archlint")

# Build and run the tests (generates the client submodule's proto bindings)
test: (_container "test")
