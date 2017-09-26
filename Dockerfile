FROM buildpack-deps:jessie

RUN /bin/cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && sed -i "s/httpredir\\.debian\\.org/cdn.debian.net/" /etc/apt/sources.list \
 && sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list \
 \
 && apt-get update 1> /dev/null \
 && apt-get upgrade -y -q --no-install-recommends \
 \
 && apt-get install -y --no-install-recommends \
 ca-certificates curl git zip jq bc vim \
 python python-yaml \
 python-pip python-dev libffi-dev \
 libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev libtidy-dev libssl-dev libicu-dev \
 \
 && apt-get -y --purge remove python-cffi \
 \
 && pip install --upgrade cffi \
 && pip install --upgrade --user awscli \
 && pip install ansible \
 \
 && apt-get -f -y --auto-remove remove \
 python-pip python-dev libffi-dev \
 \
 && apt-get clean \
 \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/*

ENV PATH /root/.local/bin:$PATH

#==================
# Docker, Docker-Compose
#==================
ENV DOCKER_CLIENT_VERSION 17.05.0-ce
ENV DOCKER_COMPOSE_VERSION 1.13.0
RUN curl -sL -o /tmp/docker-client.tgz https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_CLIENT_VERSION.tgz \
 && tar -xz -C /tmp -f /tmp/docker-client.tgz \
 && mv /tmp/docker/* /usr/bin \
 && curl -sL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` \
    >| /usr/local/bin/docker-compose \
 && chmod +x /usr/local/bin/docker-compose \
 && rm -rf /tmp/*

#==================
# Yarn
#==================
ENV YARN_VERSION 0.21.3
ENV YARN_GPG_KEY 6A010C5166006599AA17F08146C2130DFD2497F5
RUN set -ex \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$YARN_GPG_KEY" \
 && curl -sfSL -o yarn.js "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js" \
 && curl -sfSL -o yarn.js.asc "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js.asc" \
 && gpg --batch --verify yarn.js.asc yarn.js \
 && rm yarn.js.asc \
 && mv yarn.js /usr/local/bin/yarn \
 && chmod +x /usr/local/bin/yarn \
 && rm -rf /tmp/*

#==================
# Anyenv
#==================
ENV ANY_ENV_HOME /root/.anyenv
ENV PATH $ANY_ENV_HOME/bin:$PATH
COPY ansible /tmp/ansible
WORKDIR /tmp/ansible
RUN mkdir -p /etc/ansible \
 && echo 'localhost' >| /etc/ansible/hosts \
 && ansible-playbook -vvv playbook.yml \
 && rm -rf /tmp/*

WORKDIR /root
