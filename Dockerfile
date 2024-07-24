FROM php:8.0.20-apache

USER root

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    apache2-utils \
    apt-transport-https \
    bc \
    ca-certificates \
    containerd \
    curl \
    gettext-base \
    gnupg-agent \
    gnupg \
    imagemagick \
    jq \
    libargon2-dev \
    libc-client-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libkrb5-dev \
    libonig-dev \
    libpng-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev \
    make \
    p7zip-full \
    software-properties-common \
    unzip \
    wget \
    zip \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# removing as not required
#RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
#RUN docker-php-ext-install imap
#RUN docker-php-ext-install mysqli
#RUN docker-php-ext-install pdo_mysql
#RUN docker-php-ext-install bcmath
#RUN docker-php-ext-install iconv
#RUN docker-php-ext-install zip
#RUN docker-php-ext-install intl
#RUN docker-php-ext-install gd
#RUN docker-php-ext-install soap
#RUN docker-php-ext-install sockets
#RUN docker-php-ext-install pcntl
#RUN docker-php-ext-enable sodium
#RUN docker-php-ext-configure intl
#RUN printf "\n" | pecl install imagick
#RUN docker-php-ext-enable imagick

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# kubectl
RUN curl -o /usr/local/bin/kubectl -JLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

# composer
RUN mkdir -p /composer/vendor/
ENV COMPOSER_HOME=/composer
ENV PATH /composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# gitlab runner
ARG GITLAB_RUNNER_VERSION=17.0.0
RUN wget https://gitlab.com/gitlab-org/gitlab-runner/-/releases/v${GITLAB_RUNNER_VERSION}/downloads/packages/deb/gitlab-runner_amd64.deb && \
    dpkg -i gitlab-runner_amd64.deb && \
    rm gitlab-runner_amd64.deb

# kaniko
COPY kaniko-secret.yml /usr/local/bin
COPY kaniko-pod.yml /usr/local/bin
COPY build-k8s.sh /usr/local/bin
RUN chmod +x /usr/local/bin/build-k8s.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
