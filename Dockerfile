FROM archlinux:base

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    # 防止pyc文件生成
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=1\
    UV_NO_DEV=1\
    UV_NO_EDITABLE=1\
    UV_VENV_DIR=/venv
# 更换为清华源
ARG TARGETARCH

RUN echo "TARGETARCH = ${TARGETARCH}" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
    echo "x86_64 build"; \
    sed -i '1i Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch' /etc/pacman.d/mirrorlist; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    echo "ARM64 build"; \
    sed -i '1i Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/\$arch/\$repo' /etc/pacman.d/mirrorlist; \
    else \
    echo "Unknown arch: $TARGETARCH"; \
    exit 1; \
    fi
# 安装必要的软件包
RUN pacman -Syyu --noconfirm \
    openssh \
    git \
    sudo \
    tmux \
    && rm -rf /var/lib/apt/lists/*

RUN sudo pacman -S --noconfirm fish neovim yazi uv ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
# 创建SSH目录
RUN git config --global url."https://gh-proxy.com/https://github.com/".insteadOf https://github.com/
RUN sed -i 's/AllowAgentForwarding no/AllowAgentForwarding yes/' /etc/ssh/sshd_config

# uv
RUN mkdir -p /root/.config/uv
COPY configs/uv.toml /root/.config/uv/uv.toml
RUN chmod 644 /root/.config/uv/uv.toml


RUN chsh -s /bin/fish
RUN ssh-keygen -A
RUN /usr/sbin/sshd

# 暴露SSH端口
EXPOSE 22

# 启动SSH服务
CMD ["/bin/fish"]