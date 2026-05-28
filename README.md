# compute-bootstrap

Boot-time bootstrap script fetched by KalaData Compute instances via the
`BOOT_SCRIPT` environment variable. See the vast-ai/base-image
`entrypoint.sh` for the curl/exec mechanism.

## What it does

1. Waits briefly for the upstream portal template file to land.
2. Applies an idempotent set of `sed` substitutions to rebrand the
   in-container dashboard.
3. Hands off to the default boot script (`boot_default.sh`) so the rest
   of the instance bootstrap runs unchanged.

## Failure mode

If anything in this script fails, the container falls through to the
upstream default boot. Instances are not bricked by a bad bootstrap.
