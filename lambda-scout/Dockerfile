FROM python:3-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
            jq \
            unzip \
            pipx \
            curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# when running in Lambda, root filesystem is read-only
WORKDIR /tmp

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install --update \
    && rm awscliv2.zip \
    && rm -rf aws/

RUN useradd -md /scout -u 1000 scout
USER scout

# Install ScoutSuite
RUN pipx install scoutsuite
ENV PATH "$PATH:/scout/.local/bin"

COPY --chown=scout lambda-wrapper.sh /scout/lambda-wrapper.sh
COPY --chown=scout run.sh /scout/run.sh
RUN chmod +x /scout/*.sh

ENTRYPOINT ["/scout/lambda-wrapper.sh", "/scout/run.sh"]