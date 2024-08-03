# 使用官方的Julia镜像作为基础镜像
FROM julia:latest

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

# 维护者信息
LABEL maintainer="qiyang@mail.ustc.edu.com"

# 将Julia的镜像设置成非交互模式，并使用默认的提示符
ENV JULIA_HISTORY=/root/.julia/logs/REQUIRE

# 安装所需的Julia包
RUN julia -e 'using Pkg; \
    Pkg.add("OMEinsumContractionOrders") && \
    Pkg.add("Graphs") && \
    Pkg.add("KaHyPar") && \
    Pkg.precompile()'

# 可以设置工作目录，如果需要的话
WORKDIR /app

# 将你的Julia脚本复制到容器中
# COPY your_script.jl .

# 可以设置默认的命令来运行你的Julia脚本，如果需要的话
# CMD ["julia", "your_script.jl"]

# 暴露端口，方便直接连接
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]