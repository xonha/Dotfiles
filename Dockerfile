FROM archlinux:latest

# Keep package metadata fresh and install common development tools.
RUN pacman -Syu --noconfirm \
    && pacman -S --noconfirm --needed \
        base-devel \
        git \
        curl \
        wget \
        openssh \
        sudo \
        neovim \
        less \
        which \
        unzip \
        zip \
        ca-certificates \
        python \
        python-pip \
        nodejs \
        npm \
    && pacman -Scc --noconfirm

# Create a root-equivalent development user named henrique.
ARG USERNAME=henrique
RUN useradd -m -o -u 0 -g 0 -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:plambas" | chpasswd

USER ${USERNAME}
WORKDIR /workspace

# Keep the container alive for shell-based development.
CMD ["sleep", "infinity"]
