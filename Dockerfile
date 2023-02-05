FROM gitlab/gitlab-runner:v14.4.2

RUN groupadd -g 113 docker && \
    usermod -a -G docker gitlab-runner

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    bc \
    docker.io \
    gettext-base \
    jq \
    unzip \
    zip \
	p7zip-full && \
	rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/docker/compose/releases/download/v2.10.2/docker-compose-linux-x86_64 -o '/usr/local/bin/docker-compose' && \
    chmod +x /usr/local/bin/docker-compose && \
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]