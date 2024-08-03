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
    Pkg.add("OMEinsumContractionOrders"); \
    Pkg.add("OMEinsum"); \
    Pkg.add("KaHyPar"); \
    Pkg.add("YAML"); \
    Pkg.add("JSON"); \
    Pkg.precompile()'

# 可以设置工作目录，如果需要的话
WORKDIR /app

# 将你的Julia脚本复制到容器中
COPY main.jl .

ENTRYPOINT ["julia", "./main.jl"]

# Input file, output file
CMD ["--arg1", "value1", "value2", "value3"]