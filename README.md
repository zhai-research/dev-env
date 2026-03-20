# Docker 开发环境

这是一个基于 Ubuntu 24.04 的精简 Docker 开发环境，只包含 uv (Python 包管理器)。

## 使用说明

### 本地构建和运行

```bash
# 构建镜像
docker build -t dev-env .

# 运行容器
docker run --rm -it dev-env

# 运行并挂载当前目录
docker run --rm -it -v $(pwd):/workspace -w /workspace dev-env
```

### 使用 Docker Compose

```bash
# 启动
docker-compose up -d

# 进入容器
docker-compose exec dev-env bash

# 停止
docker-compose down
```

## 包含的内容

- Ubuntu 24.04 LTS
- [uv](https://github.com/astral-sh/uv) - 极速 Python 包管理器和运行器
- 清华 PyPI 镜像源配置

## 使用 uv

```bash
# 创建虚拟环境
uv venv

# 安装包
uv pip install requests

# 运行 Python 脚本
uv run script.py

# 使用特定 Python 版本
uv python install 3.12
uv run --python 3.12 script.py
```

## 自定义

修改 `Dockerfile` 添加更多工具，或修改 `configs/uv.toml` 更改 uv 配置。

## 镜像仓库

- GitHub: https://github.com/zhai-research/dev-env
