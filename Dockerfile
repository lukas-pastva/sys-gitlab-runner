FROM gitlab/gitlab-runner:v15.11.0

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    apache2-utils \
    bc \
    gettext-base \
    jq \
    unzip \
    zip \
	p7zip-full && \
	rm -rf /var/lib/apt/lists/*

# kubectl
RUN curl -o /usr/local/bin/kubectl -JLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

COPY kaniko.yml /usr/local/bin
COPY build-k8s.sh /usr/local/bin
RUN chmod +x /usr/local/bin/build-k8s.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]