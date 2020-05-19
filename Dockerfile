FROM ubuntu:latest

WORKDIR /var/tmp
RUN apt-get update && \
    apt-get install -y wget \
                       unzip \
                       ssh &&\
    wget "https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip"  && \
    unzip terraform_0.12.24_linux_amd64.zip && \
    wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"  && \
    unzip awscli-exe-linux-x86_64.zip && \
    ./aws/install  && \
    rm -f terraform_0.12.24_linux_amd64.zip \
          awscli-exe-linux-x86_64.zip &&\
    mv terraform /usr/local/bin/
