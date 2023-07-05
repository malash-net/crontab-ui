# docker run -d -p 8000:8000 alseambusher/crontab-ui
FROM ubuntu:22.04

ENV TZ=Asia/Shanghai
RUN  apt-get update && apt-get install -y \
  wget \
  curl \
  supervisor \
  tzdata \
  jq \
  cron \
  && rm -rf /var/lib/apt/lists/*
RUN rm -rf /etc/localtime \
  && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata

ENV NODE_VERSION=16.20.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

RUN mv /var/spool/cron/crontabs /etc/crontabs && ln -s /etc/crontabs /var/spool/cron/crontabs
ENV CRON_PATH /etc/crontabs
RUN mkdir /crontab-ui; touch $CRON_PATH/root; chmod +x $CRON_PATH/root
WORKDIR /crontab-ui

LABEL maintainer "@alseambusher"
LABEL description "Crontab-UI docker"

COPY supervisord.conf /etc/supervisord.conf
COPY . /crontab-ui

RUN npm install

ENV HOST 0.0.0.0
ENV PORT 8000
ENV   CRON_IN_DOCKER true
EXPOSE $PORT

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
