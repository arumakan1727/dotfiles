# Linux test environment for the chezmoi-based dotfiles.
#
# Simulates a *fresh* machine: only the bare prerequisites assumed by the
# bootstrap (git + curl + sha256sum + a shell + the tar/unzip used to unpack
# release tarballs). Everything else must come from the bootstrap + chezmoi +
# mise flow under test — do NOT pre-install chezmoi or mise here.
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      tar \
      gzip \
      xz-utils \
      unzip \
      zsh \
      bash \
      less \
      procps \
      coreutils \
  && rm -rf /var/lib/apt/lists/*

# Run as an unprivileged user, like a real account (home = /home/tester).
RUN useradd --create-home --shell /bin/bash --uid 1000 tester
USER tester
WORKDIR /home/tester
ENV HOME=/home/tester

# in-container.sh is executed from the read-only bind mount at /src.
CMD ["/src/test/in-container.sh", "smoke"]
