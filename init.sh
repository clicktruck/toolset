#!/usr/bin/env bash

main() {

  # Manage software versions installed here
  AGE_VERSION=1.1.1
  ARGO_VERSION=3.5.5
  ARGOCD_VERSION=2.10.7
  BOSH_VERSION=7.5.6
  CF_VERSION=8.7.10
  CREDHUB_VERSION=2.9.22
  HELM_VERSION=3.14.4
  HELMFILE_VERSION=0.158.1
  AWS_IAM_AUTHENTICATOR_VERSION=0.6.11
  IMGPKG_VERSION=0.42.1
  K9S_VERSION=0.32.4
  KAPP_VERSION=0.62.0
  KBLD_VERSION=0.43.0
  KCTRL_VERSION=0.51.0
  KIND_VERSION=0.22.0
  KPACK_CLI_VERSION=0.13.0
  KWT_VERSION=0.0.8
  KUBECTL_VERSION=1.29.4
  KNATIVE_VERSION=1.13.0
  LEFTOVERS_VERSION=0.62.0
  OCI_CLI_VERSION=3.40.1
  OM_VERSION=7.10.1
  PINNIPED_VERSION=0.29.0
  PIVNET_VERSION=4.1.1
  RELOK8S_VERSION=0.5.4
  SOPS_VERSION=3.8.1
  TEKTONCD_VERSION=0.36.0
  TERRAFORM_VERSION=1.8.0
  TERRAFORM_DOCS_VERSION=0.17.0
  VELERO_VERSION=1.13.2
  VENDIR_VERSION=0.40.1
  YTT_VERSION=0.49.0

  DEBIAN_FRONTEND=noninteractive

  # Place ourselves in a temporary directory; don't clutter user.home directory w/ downloaded artifacts
  cd /tmp || exit

  # Set timezone
  TZ=America/Los_Angeles
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

  # Bring OS package management up-to-date
  apt update -y
  apt upgrade -y

  # Install packages from APT
  apt install build-essential curl default-jre git golang-go gpg graphviz gzip httpie libnss3-tools jq openssl pv python3-pip python3-dev python3-venv ruby-dev snapd tmux tree tzdata unzip wget -y
  apt install apt-transport-https ca-certificates gnupg lsb-release software-properties-common dirmngr vim -y
  add-apt-repository ppa:cncf-buildpacks/pack-cli -y
  apt install pack-cli -y

  # Install packages from Snap
  snap install snap-store
  snap install cvescan

  # Install Github CLI
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  apt update
  apt install gh -y

  # Install K9s
  curl -LO https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_amd64.tar.gz
  tar -xvf k9s_Linux_amd64.tar.gz
  rm -Rf k9s_Linux_amd64.tar.gz
  mv k9s /usr/local/bin

  # Install NodeJS
  curl -fsSL https://deb.nodesource.com/setup_19.x | -E bash -
  apt-get install -y nodejs

  # Install Python 3
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user virtualenv

  # Install eksctl
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  mv /tmp/eksctl /usr/local/bin

  # Install Docker Engine
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt update
  apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  groupadd docker
  usermod -aG docker ubuntu
  newgrp docker
  systemctl enable docker.service
  systemctl enable containerd.service
  docker run --rm hello-world

  # Install AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install

  # Install AWS IAM Authenticator
  curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64
  chmod +x aws-iam-authenticator
  mv aws-iam-authenticator /usr/local/bin

  # Install Azure CLI
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash

  # Install Google Cloud SDK
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  apt update -y && apt install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin -y

  # Install Oracle Cloud CLI
  curl -LO https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
  chmod +x install.sh
  ./install.sh --accept-all-defaults --oci-cli-version ${OCI_CLI_VERSION}

  # Install Cloud Foundry UAA CLI
  gem install cf-uaac

  # Install age file encryption
  curl -LO https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz
  tar -xvf age-v${AGE_VERSION}-linux-amd64.tar.gz
  rm -Rf age-v${AGE_VERSION}-linux-amd64.tar.gz
  mv age/age* /usr/local/bin

  # Install BOSH CLI
  wget https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64
  mv bosh-cli-${BOSH_VERSION}-linux-amd64 bosh
  chmod +x bosh
  mv bosh /usr/local/bin

  # Install Cloud Foundry CLI
  wget -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_VERSION}&source=github-rel"
  tar -xvf cf.tgz
  rm -Rf cf.tgz
  cp cf8 /usr/local/bin/cf

  # Install Credhub CLI
  wget https://github.com/cloudfoundry/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz
  tar -xvzf credhub-linux-${CREDHUB_VERSION}.tgz
  rm -Rf credhub-linux-${CREDHUB_VERSION}.tgz
  mv credhub /usr/local/bin

  # Install kubectl
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
  chmod +x kubectl
  mv kubectl /usr/local/bin

  # Install Knative
  curl -L -o kn https://github.com/knative/client/releases/download/knative-v${KNATIVE_VERSION}/kn-linux-amd64
  chmod +x kn
  mv kn /usr/local/bin

  # Install Operations Manager CLI (for Cloud Foundry)
  wget https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux-amd64-${OM_VERSION}
  mv om-linux-amd64-${OM_VERSION} om
  chmod +x om
  mv om /usr/local/bin

  # Install Tanzu Network CLI (formerly Pivotal Network CLI)
  wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v${PIVNET_VERSION}/pivnet-linux-amd64-${PIVNET_VERSION}
  mv pivnet-linux-amd64-${PIVNET_VERSION} pivnet
  chmod +x pivnet
  mv pivnet /usr/local/bin

  # Install Terraform
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  mv terraform /usr/local/bin

  # Install Terraform-Docs
  curl -Lo ./terraform-docs https://github.com/segmentio/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-"$(uname | tr '[:upper:]' '[:lower:]')-amd64"
  chmod +x ./terraform-docs
  mv terraform-docs /usr/local/bin

  # Install leftovers - helps to clean up orphaned resources created in a public cloud
  wget https://github.com/genevieve/leftovers/releases/download/v${LEFTOVERS_VERSION}/leftovers-v${LEFTOVERS_VERSION}-linux-amd64
  mv leftovers-v${LEFTOVERS_VERSION}-linux-amd64 leftovers
  chmod +x leftovers
  mv leftovers /usr/local/bin

  # Install Tanzu CLI (and plugins)
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub | gpg --dearmor -o /etc/apt/keyrings/tanzu-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/tanzu-archive-keyring.gpg] https://storage.googleapis.com/tanzu-cli-os-packages/apt tanzu-cli-jessie main" | tee /etc/apt/sources.list.d/tanzu.list
  apt update
  apt install -y tanzu-cli
  tanzu config eula accept
  TANZU_CLI_CEIP_OPT_IN_PROMPT_ANSWER="no"
  tanzu plugin group search
  tanzu plugin install --group vmware-tanzucli/essentials
  tanzu plugin install --group vmware-tap/default
  tanzu plugin install --group vmware-tap_saas/app-developer
  tanzu plugin install --group vmware-tap_saas/platform-engineer
  tanzu plugin install --group vmware-tkg/default
  tanzu plugin install --group vmware-tmc/default
  tanzu plugin install --group vmware-vsphere/default

  # Install Helm
  curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
  tar -xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
  mv linux-amd64/helm /usr/local/bin

  # Install Helmfile
  curl -LO "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz"
  tar -xvf helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz
  mv helmfile /usr/local/bin


  # Install full complement of Carvel toolset
  wget -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64
  chmod +x imgpkg
  mv imgpkg /usr/local/bin
  wget -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64
  chmod +x ytt
  mv ytt /usr/local/bin
  wget -O vendir https://github.com/vmware-tanzu/carvel-vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64
  chmod +x vendir
  mv vendir /usr/local/bin
  wget -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64
  chmod +x kapp
  mv kapp /usr/local/bin
  wget -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64
  chmod +x kbld
  mv kbld /usr/local/bin
  wget -O kwt https://github.com/vmware-tanzu/carvel-kwt/releases/download/v${KWT_VERSION}/kwt-linux-amd64
  chmod +x kwt
  mv kwt /usr/local/bin
  wget -O kctrl https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v${KCTRL_VERSION}/kctrl-linux-amd64
  chmod +x kctrl
  mv kctrl /usr/local/bin

  # Install Minio CLI
  curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x mc
  mv mc /usr/local/bin

  # Install Argo CD and Argo Workflows CLIs
  wget -O argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64
  chmod +x argocd
  mv argocd /usr/local/bin
  curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_VERSION}/argo-linux-amd64.gz
  gunzip argo-linux-amd64.gz
  chmod +x argo-linux-amd64
  mv argo-linux-amd64 /usr/local/bin/argo

  # Install Tekton CD CLI
  curl -LO https://github.com/tektoncd/cli/releases/download/v${TEKTONCD_VERSION}/tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz
  tar -xvf tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz
  chmod +x tkn
  mv tkn /usr/local/bin

  # Install mkcert
  git clone https://github.com/FiloSottile/mkcert && cd mkcert || exit
  go build -ldflags "-X main.Version=$(git describe --tags)"
  mv mkcert /usr/local/bin
  cd ..
  rm -Rf mkcert

  # Install kpack-cli
  curl -Lo ./kp https://github.com/vmware-tanzu/kpack-cli/releases/download/v${KPACK_CLI_VERSION}/kp-linux-${KPACK_CLI_VERSION}
  chmod +x ./kp
  mv ./kp /usr/local/bin

  # Install kind
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
  chmod +x ./kind
  mv ./kind /usr/local/bin

  # Install Velero
  curl -LO https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz
  tar -xvf velero-v${VELERO_VERSION}-linux-amd64.tar.gz
  chmod +x velero-v${VELERO_VERSION}-linux-amd64/velero
  mv velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin

  # Install cmctl; @see https://cert-manager.io/docs/usage/cmctl/
  curl -L -o cmctl.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/cmctl-linux-amd64.tar.gz
  tar xzf cmctl.tar.gz
  mv cmctl /usr/local/bin

  # Install relok8s
  curl -LO https://github.com/vmware-tanzu/asset-relocation-tool-for-kubernetes/releases/download/v${RELOK8S_VERSION}/relok8s_${RELOK8S_VERSION}_linux_x86_64.tar.gz
  tar -xvf relok8s_${RELOK8S_VERSION}_linux_x86_64.tar.gz
  chmod +x relok8s
  mv relok8s /usr/local/bin

  # Install Mozilla Secrets for Operations
  curl -LO https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64
  mv sops-v${SOPS_VERSION}.linux.amd64 sops
  chmod +x sops
  mv sops /usr/local/bin

  # Install pinniped
  curl -Lso pinniped https://get.pinniped.dev/v${PINNIPED_VERSION}/pinniped-cli-linux-amd64
  chmod +x pinniped
  mv pinniped /usr/local/bin

  # Install yq
  wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  chmod a+x /usr/local/bin/yq

  # Clean-up APT cache
  rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  apt clean

}

main
