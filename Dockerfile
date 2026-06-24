# Docker 会自动注入 TARGETARCH 变量
ARG TARGETARCH

# 根据架构选择不同的基础镜像
FROM --platform=linux/amd64 dokken/debian-13:latest AS base-amd64
FROM --platform=linux/arm64 dokken/debian-13:latest AS base-arm64

# 选择对应的基础镜像
FROM base-${TARGETARCH}

# Docker 会自动注入 TARGETARCH 变量
ARG TARGETARCH

# 设置工作目录为 /root
WORKDIR /root

# 确保容器以 root 用户运行
USER root

# 安装curl和SSH
RUN apt update && apt install -y curl openssh-server

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#Port 22/Port 6633/' /etc/ssh/sshd_config \
 && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# 创建root用户密码
RUN mkdir -p /var/run/sshd && echo 'root:q09995' | chpasswd

# 安装GO环境
RUN apt update && \
    apt install -y golang-go && \
    go version

# 容器启动时运行的命令
ENTRYPOINT ["/usr/lib/systemd/systemd"]
