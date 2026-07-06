FROM ubuntu:24.04

ARG USERNAME=dev

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    PIP_BREAK_SYSTEM_PACKAGES=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ack \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    exuberant-ctags \
    git \
    htop \
    jq \
    less \
    locales \
    lsof \
    make \
    man-db \
    netcat-openbsd \
    net-tools \
    openssh-client \
    openssh-server \
    pipx \
    psmisc \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    ripgrep \
    rsync \
    socat \
    strace \
    sudo \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    zip \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN ssh-keygen -A \
    && mkdir -p /var/run/sshd \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && echo "StrictModes no" >> /etc/ssh/sshd_config

RUN printf '#!/bin/bash\nset -e\nsudo /usr/sbin/sshd -e\nexec "$@"\n' > /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN groupmod -n ${USERNAME} ubuntu \
    && usermod -l ${USERNAME} -d /home/${USERNAME} -m ubuntu \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Install Node.js / npm (LTS via NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install gh CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "arm64" ]; then AWS_ARCH="aarch64"; else AWS_ARCH="x86_64"; fi \
    && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

RUN mkdir -p /home/${USERNAME}/workspace \
    && chown ${USERNAME}:${USERNAME} /home/${USERNAME}/workspace

# Start with apt-get cache pre-warmed to avoid confusing errors when I inevitably
# try to install something this Dockerfile forgot.
RUN apt-get update

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sleep", "infinity"]
