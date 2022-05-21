FROM debian:bullseye-backports
RUN apt update && apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    golang-1.16-go \
    make \
    git \
    build-essential \
    libssl-dev \
    g++ \
    markdown \
    libappindicator3*-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev
RUN addgroup --system --quiet --gid 1000 user
RUN adduser --disabled-password --gecos "" --uid 1000 --gid 1000 --shell /bin/bash --home /home/user user
COPY . /home/user/go/src/i2pgit.org/idk/railroad
WORKDIR /home/user/go/src/i2pgit.org/idk/railroad
RUN chown -R user:user /home/user
CMD /usr/lib/go-1.16/bin/go mod vendor && GOOS=linux make rb