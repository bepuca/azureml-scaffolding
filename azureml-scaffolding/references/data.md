# Data Workflows (Optional)

Use this pattern when teams only need a simple, repeatable download flow.

## What this adds

- One explicit command for pulling data from [Blob Storage][blob-storage] into `./data`.
- A minimal contract that does not assume any global data abstraction.
- A concise positional-argument interface for teams that prefer shell-style usage.

## Minimal target to add

Add a single target to the root `Makefile`:

```makefile
data-download: ## Download blob data into ./data
  @test -n "$(ARGS)" || { echo "usage: make data-download ARGS='<account> <container> <pattern>'"; exit 1; }
  @test -n "$(TENANT_ID)" || { echo "TENANT_ID is not set"; exit 1; }
  @mkdir -p data
  @set -- $(ARGS); \
  [ $$# -eq 3 ] || { echo "usage: make data-download ARGS='<account> <container> <pattern>'"; exit 1; }; \
  account="$$1"; container="$$2"; pattern="$$3"; \
  AZCOPY_AUTO_LOGIN_TYPE=azcli AZCOPY_TENANT_ID="$(TENANT_ID)" azcopy copy \
    "https://$$account.blob.core.windows.net/$$container" \
    "data" \
    --recursive --include-regex "$$pattern"
```

Example:

```bash
make data-download ARGS='myacct mycontainer ^datasets/train/.*'
```

## Prerequisites

- Logged-in [Azure CLI][az-cli] session and `TENANT_ID` defined in `.env.local`.
- [`azcopy`][azcopy] must be installed in the runtime where this command is executed.
- For Debian/Ubuntu images, add Microsoft package registry first, then install
  `azcopy`:

```dockerfile
RUN curl -sSL -O https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends azcopy
```

## Agent guidance

- Offer this extension when users ask for a lightweight, repeatable way to
  pull files from blob storage.

[blob-storage]: https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction
[az-cli]: https://learn.microsoft.com/en-us/cli/azure/
[azcopy]: https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10