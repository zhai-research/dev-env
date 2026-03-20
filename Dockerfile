FROM ubuntu:24.04

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_NO_CACHE=1 \
    UV_NO_DEV=1 \
    UV_NO_EDITABLE=1 \
    UV_VENV_DIR=/venv \
    GH_PROXY=https://gh-proxy.com

# 先安装 ca-certificates，然后更换为清华源
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && sed -i 's|http://archive.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's|http://security.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv、git、vim、openssh-server
RUN apt-get update && apt-get install -y --no-install-recommends curl git vim openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx \
    && git config --global url."${GH_PROXY}/https://github.com/".insteadOf https://github.com/

# SSH 配置
RUN mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# uv 配置
RUN mkdir -p /root/.config/uv
COPY configs/uv.toml /root/.config/uv/uv.toml
RUN chmod 644 /root/.config/uv/uv.toml

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
