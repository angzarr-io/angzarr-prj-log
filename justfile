# angzarr-prj-log: minimal recipe set. Day-to-day work is `cargo`.
# This justfile exists primarily to wire in the shared submodule-protection
# recipes (install-submodule-hooks, check-submodules-clean) from
# angzarr-project. Source of truth: angzarr-project/submodule.just.
import? 'angzarr-project/submodule.just'

default:
    @just --list
