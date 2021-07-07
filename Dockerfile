FROM canal/osbase:v1

MAINTAINER Luo Tao (lotreal@gmail.com)

# install canal
COPY canal.deployer-*.tar.gz /opt/

RUN \
    mkdir -p /opt/canal-deployer && \
    tar -xzvf /opt/canal.deployer-*.tar.gz -C /opt/canal-deployer && \
    /bin/rm -f /opt/canal.deployer-*.tar.gz && \

    mkdir -p /opt/canal-deployer/logs/canal && \
    yum clean all && \
    true

COPY app.sh /app.sh

# 2222 sys , 8000 debug , 11111 canal , 11112 metrics
EXPOSE 2222 11111 8000 11112

WORKDIR /opt/canal-deployer
CMD [ "/app.sh" ]
