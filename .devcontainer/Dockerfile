# aws-open-lab — CLI toolchain for labs 1–6+ (AWS, GitHub, IaC, MCP).
FROM mcr.microsoft.com/devcontainers/base:noble

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    curl \
    direnv \
    git \
    gnupg \
    jq \
    lsb-release \
    make \
    python3 \
    python3-pip \
    python3-venv \
    shellcheck \
    unzip \
    wget \
    yq \
  && rm -rf /var/lib/apt/lists/*

# --- GitHub CLI (latest stable) ---
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

# --- HashiCorp Terraform (Lab 6+) ---
RUN wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends terraform \
  && rm -rf /var/lib/apt/lists/*

# --- Node.js 22 LTS + AWS CDK CLI (Lab 6+) ---
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && npm install -g aws-cdk@2 \
  && rm -rf /var/lib/apt/lists/*

# --- uv / uvx (AWS MCP proxy) — system-wide ---
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" INSTALLER_NO_MODIFY_PATH=1 sh

# --- AWS CLI v2 (official bundle) ---
RUN case "${TARGETARCH}" in \
    amd64) AWS_ARCH=x86_64 ;; \
    arm64) AWS_ARCH=aarch64 ;; \
    *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
  esac \
  && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip \
  && unzip -q /tmp/awscliv2.zip -d /tmp \
  && /tmp/aws/install \
  && rm -rf /tmp/aws /tmp/awscliv2.zip

# --- Session Manager plugin (SSM / EC2 later labs) ---
RUN case "${TARGETARCH}" in \
    amd64) SSM_ARCH=64bit ;; \
    arm64) SSM_ARCH=arm64 ;; \
    *) echo "Unsupported TARGETARCH for SSM plugin: ${TARGETARCH}" >&2; exit 1 ;; \
  esac \
  && curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${SSM_ARCH}/session-manager-plugin.deb" \
    -o /tmp/session-manager-plugin.deb \
  && dpkg -i /tmp/session-manager-plugin.deb \
  && rm -f /tmp/session-manager-plugin.deb

# --- kubectl (optional EKS/containers labs) ---
RUN case "${TARGETARCH}" in \
    amd64) KUBE_ARCH=amd64 ;; \
    arm64) KUBE_ARCH=arm64 ;; \
    *) echo "Unsupported TARGETARCH for kubectl: ${TARGETARCH}" >&2; exit 1 ;; \
  esac \
  && curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${KUBE_ARCH}/kubectl" \
    -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

# --- AWS SAM CLI (serverless lab stretch) — venv avoids apt PyYAML conflict ---
RUN python3 -m venv /opt/sam-cli \
  && /opt/sam-cli/bin/pip install --upgrade pip \
  && /opt/sam-cli/bin/pip install aws-sam-cli \
  && ln -sf /opt/sam-cli/bin/sam /usr/local/bin/sam

LABEL org.opencontainers.image.description="AWS Open Lab devcontainer — aws, gh, terraform, cdk, jq, uv, sam, kubectl, ssm plugin"
