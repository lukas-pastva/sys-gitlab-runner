FROM gitlab/gitlab-runner:v15.11.0

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    apache2-utils \
    bc \
    gettext-base \
    jq \
    unzip \
    zip \
	p7zip-full \
    curl \
    software-properties-common \
    gnupg-agent && \
    rm -rf /var/lib/apt/lists/*

# kubectl
RUN curl -o /usr/local/bin/kubectl -JLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

COPY kaniko.yml /usr/local/bin
COPY build-k8s.sh /usr/local/bin
RUN chmod +x /usr/local/bin/build-k8s.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
