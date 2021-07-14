FROM openjdk:8

MAINTAINER Luo Tao (luotao@easi.com.au)

RUN \
    mkdir -p /opt/canal-deployer && \
    wget -nv -P /opt https://github.com/alibaba/canal/releases/download/canal-1.1.5/canal.deployer-1.1.5.tar.gz && \
    tar -xzvf /opt/canal.deployer-1.1.5.tar.gz -C /opt/canal-deployer && \
    /bin/rm -f /opt/canal.deployer-1.1.5.tar.gz

COPY app.sh /app.sh

# 2222 sys , 8000 debug , 11111 canal , 11112 metrics
EXPOSE 2222 11111 8000 11112

WORKDIR /opt/canal-deployer

CMD [ "/app.sh" ]
