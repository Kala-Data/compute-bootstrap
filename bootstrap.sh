#!/bin/bash
#
# KalaData Compute — boot-time bootstrap fetched by GPU instances via the
# `BOOT_SCRIPT` env var (see vast-ai/base-image entrypoint.sh).
#
# Rebrands the in-container portal-aio HTML before portal-aio starts, then
# hands off to vast's default boot script so the rest of the stack
# (key propagation, supervisord, Open WebUI, Jupyter, etc.) runs unchanged.
#
# Designed to be a no-op if anything goes wrong — falls through to default
# boot rather than blocking the container.
#

set -e

PORTAL_HTML="/opt/portal-aio/portal/templates/index.html"

# Wait briefly for the template file to land (image layers may unpack lazily).
for _ in $(seq 1 20); do
  [ -f "$PORTAL_HTML" ] && break
  sleep 1
done

# In-place rebrand of the hardcoded strings in the portal HTML. Idempotent —
# only matches the upstream literals, so re-running on already-rebranded
# content is safe.
if [ -f "$PORTAL_HTML" ]; then
  sed -i \
    -e 's|Vast\.ai Instance Portal|KalaData Compute Portal|g' \
    -e 's|>Vast\.ai<|>KalaData<|g' \
    -e 's|Loading Instance Portal|Loading KalaData Portal|g' \
    -e 's|<h3>Instance Portal</h3>|<h3>KalaData Portal</h3>|g' \
    -e 's|The Instance Portal is|The KalaData Portal is|g' \
    -e 's|New to Vast\.ai?|New to KalaData?|g' \
    -e 's|Integrate Vast\.ai into your own tools|Integrate KalaData into your own tools|g' \
    -e 's|Vast\.ai infrastructure|KalaData infrastructure|g' \
    "$PORTAL_HTML" 2>/dev/null || true
fi

# Hand off to default boot — replaces our process so the rest of vast's
# bootstrap chain runs as if nothing happened.
exec /opt/instance-tools/bin/boot_default.sh "$@"
