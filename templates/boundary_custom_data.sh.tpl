#!/usr/bin/env bash
set -euo pipefail

LOGFILE="/var/log/boundary-cloud-init.log"
SYSTEMD_DIR="${systemd_dir}"
BOUNDARY_DIR_CONFIG="${boundary_dir_config}"
BOUNDARY_CONFIG_PATH="$BOUNDARY_DIR_CONFIG/controller.hcl"
BOUNDARY_DIR_TLS="${boundary_dir_config}/tls"
BOUNDARY_DIR_DATA="${boundary_dir_home}/data"
BOUNDARY_DIR_LICENSE="${boundary_dir_home}/license"
BOUNDARY_LICENSE_PATH="$BOUNDARY_DIR_LICENSE/license.hclic"
BOUNDARY_DIR_LOGS="/var/log/boundary"
BOUNDARY_DIR_BIN="${boundary_dir_bin}"
BOUNDARY_USER="boundary"
BOUNDARY_GROUP="boundary"
PRODUCT="boundary"
BOUNDARY_VERSION="${boundary_version}"
VERSION=$BOUNDARY_VERSION
REQUIRED_PACKAGES="jq unzip"
ADDITIONAL_PACKAGES="${additional_package_names}"

function log {
  local level="$1"
  local message="$2"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local log_entry="$timestamp [$level] - $message"

  echo "$log_entry" | tee -a "$LOGFILE"
}
function detect_architecture {
  local ARCHITECTURE=""
  local OS_ARCH_DETECTED=$(uname -m)

  case "$OS_ARCH_DETECTED" in
    "x86_64"*)
      ARCHITECTURE="linux_amd64"
      ;;
    "aarch64"*)
      ARCHITECTURE="linux_arm64"
      ;;
		"arm"*)
      ARCHITECTURE="linux_arm"
			;;
    *)
      log "ERROR" "Unsupported architecture detected: '$OS_ARCH_DETECTED'. "
		  exit_script 1
			;;
  esac

  echo "$ARCHITECTURE"

}

function detect_os_distro {
  local OS_DISTRO_NAME=$(grep "^NAME=" /etc/os-release | cut -d"\"" -f2)
  local OS_DISTRO_DETECTED

  case "$OS_DISTRO_NAME" in
  "Ubuntu"*)
    OS_DISTRO_DETECTED="ubuntu"
    ;;
  "CentOS Linux"*)
    OS_DISTRO_DETECTED="centos"
    ;;
  "Red Hat"*)
    OS_DISTRO_DETECTED="rhel"
    ;;
  *)
    log "ERROR" "'$OS_DISTRO_NAME' is not a supported Linux OS distro for Boundary."
    exit_script 1
    ;;
  esac
  echo "$OS_DISTRO_DETECTED"
}

function install_prereqs {
  local OS_DISTRO="$1"
  log "INFO" "Installing required packages..."

  if [[ "$OS_DISTRO" == "ubuntu" ]]; then
    apt-get update -y
    apt-get install -y $REQUIRED_PACKAGES $ADDITIONAL_PACKAGES
  elif [[ "$OS_DISTRO" == "rhel" ]]; then
    dnf install -y $REQUIRED_PACKAGES $ADDITIONAL_PACKAGES
  else
    log "ERROR" "Unsupported OS distro '$OS_DISTRO'. Exiting."
    exit_script 1
  fi
}


function install_azcli() {
  local OS_DISTRO="$1"
  local OS_MAJOR_VERSION=$(grep "^VERSION_ID=" /etc/os-release | cut -d"\"" -f2 | cut -d"." -f1)
	log "INFO" "Detected OS major version: $OS_MAJOR_VERSION"

  if command -v az > /dev/null; then
    log "INFO" "Detected 'az' (azure-cli) is already installed. Skipping."
  else
    if [[ "$OS_DISTRO" == "ubuntu" ]]; then
      log "INFO" "Installing Azure CLI for Ubuntu."
      curl -sL https://aka.ms/InstallAzureCLIDeb | bash
    elif [[ "$OS_DISTRO" == "rhel" || "$OS_DISTRO" == "centos" ]]; then
      log "INFO" "Installing Azure CLI for RHEL $OS_MAJOR_VERSION."
			rpm --import https://packages.microsoft.com/keys/microsoft.asc
      dnf install -y https://packages.microsoft.com/config/rhel/$OS_MAJOR_VERSION/packages-microsoft-prod.rpm
      dnf install -y azure-cli
    fi
  fi
}

function scrape_vm_info {
  log "INFO" "Scraping VM metadata for private IP address..."
  VM_PRIVATE_IP=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2021-02-01&format=text")
  log "INFO" "Detected VM private IP address is '$VM_PRIVATE_IP'."
}

# user_create creates a dedicated linux user for Boundary
function user_group_create {
  log "INFO" "Creating Boundary user and group..."

  # Create the dedicated as a system group
  sudo groupadd --system $BOUNDARY_GROUP

  # Create a dedicated user as a system user
  sudo useradd --system --no-create-home -d $BOUNDARY_DIR_CONFIG -g $BOUNDARY_GROUP $BOUNDARY_USER

  log "INFO" "Done creating Boundary user and group"
}

function directory_create {
  log "INFO" "Creating necessary directories..."

  # Define all directories needed as an array
  directories=($BOUNDARY_DIR_CONFIG $BOUNDARY_DIR_DATA $BOUNDARY_DIR_TLS $BOUNDARY_DIR_LICENSE $BOUNDARY_DIR_LOGS)

  # Loop through each item in the array; create the directory and configure permissions
  for directory in "$${directories[@]}"; do
    log "INFO" "Creating $directory"

    mkdir -p $directory
    sudo chown $BOUNDARY_USER:$BOUNDARY_GROUP $directory
    sudo chmod 750 $directory
  done

  log "INFO" "Done creating necessary directories."
}

function checksum_verify {
  local OS_ARCH="$1"

  # https://www.hashicorp.com/en/trust/security
  # checksum_verify downloads the $$PRODUCT binary and verifies its integrity
  log "INFO" "Verifying the integrity of the $${PRODUCT} binary."
  export GNUPGHOME=./.gnupg
  log "INFO" "Importing HashiCorp GPG key."
  sudo curl -s https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import

	log "INFO" "Downloading $${PRODUCT} binary"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_"$${OS_ARCH}".zip
	log "INFO" "Downloading $${PRODUCT}  Enterprise binary checksum files"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_SHA256SUMS
	log "INFO" "Downloading $${PRODUCT}  Enterprise binary checksum signature file"
  sudo curl -Os https://releases.hashicorp.com/"$${PRODUCT}"/"$${VERSION}"/"$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig
  log "INFO" "Verifying the signature file is untampered."
  gpg --verify "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS
	if [[ $? -ne 0 ]]; then
		log "ERROR" "Gpg verification failed for SHA256SUMS."
		exit_script 1
	fi
  if [ -x "$(command -v sha256sum)" ]; then
		log "INFO" "Using sha256sum to verify the checksum of the $${PRODUCT} binary."
		sha256sum -c "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS --ignore-missing
	else
		log "INFO" "Using shasum to verify the checksum of the $${PRODUCT} binary."
		shasum -a 256 -c "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS --ignore-missing
	fi
	if [[ $? -ne 0 ]]; then
		log "ERROR" "Checksum verification failed for the $${PRODUCT} binary."
		exit_script 1
	fi

	log "INFO" "Checksum verification passed for the $${PRODUCT} binary."

	log "INFO" "Removing the downloaded files to clean up"
	sudo rm -f "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS "$${PRODUCT}"_"$${VERSION}"_SHA256SUMS.sig

}

function install_boundary_binary {
  local OS_ARCH="$1"

  log "INFO" "Deploying Boundary binary to $BOUNDARY_DIR_BIN unzip and set permissions"
  sudo unzip "$${PRODUCT}"_"$${BOUNDARY_VERSION}"_"$${OS_ARCH}".zip  boundary -d $BOUNDARY_DIR_BIN
  sudo unzip "$${PRODUCT}"_"$${BOUNDARY_VERSION}"_"$${OS_ARCH}".zip -x boundary -d $BOUNDARY_DIR_LICENSE
  sudo rm -f "$${PRODUCT}"_"$${BOUNDARY_VERSION}"_"$${OS_ARCH}".zip

	log "INFO" "Deploying Boundary $BOUNDARY_DIR_BIN set permissions"
  sudo chmod 0755 $BOUNDARY_DIR_BIN/boundary
  sudo chown $BOUNDARY_USER:$BOUNDARY_GROUP $BOUNDARY_DIR_BIN/boundary

  log "INFO" "Deploying Boundary create symlink "
  sudo ln -sf $BOUNDARY_DIR_BIN/boundary /usr/local/bin/boundary

  log "INFO" "Boundary binary installed successfully at $BOUNDARY_DIR_BIN/boundary"
}

function retrieve_license_from_kv() {
  log "INFO" "Retrieving Boundary license '${boundary_license_key_vault_secret_id}' from Key Vault."
  BOUNDARY_LICENSE=$(az keyvault secret show --id "${boundary_license_key_vault_secret_id}" --query value --output tsv)
  az keyvault secret show --id "${boundary_license_key_vault_secret_id}" --query value --output tsv >$BOUNDARY_LICENSE_PATH
}

function retrieve_certs_from_kv() {
  log "INFO" "Retrieving TLS certificate '${boundary_tls_cert_key_vault_secret_id}' from Key Vault."
  az keyvault secret show --id "${boundary_tls_cert_key_vault_secret_id}" --query value --output tsv | base64 -d >$BOUNDARY_DIR_TLS/cert.pem
  log "INFO" "Retrieving TLS private key '${boundary_tls_privkey_key_vault_secret_id}' from Key Vault."
  az keyvault secret show --id "${boundary_tls_privkey_key_vault_secret_id}" --query value --output tsv | base64 -d >$BOUNDARY_DIR_TLS/key.pem
%{ if boundary_tls_ca_bundle_key_vault_secret_id != "NONE" ~}
  log "INFO" "Retrieving TLS CA bundle '${boundary_tls_ca_bundle_key_vault_secret_id}' from Key Vault."
  az keyvault secret show --id "${boundary_tls_ca_bundle_key_vault_secret_id}" --query value --output tsv | base64 -d >$BOUNDARY_DIR_TLS/bundle.pem
%{ endif ~}
  chown -R $BOUNDARY_USER:$BOUNDARY_GROUP $BOUNDARY_DIR_TLS
  chmod 640 $BOUNDARY_DIR_TLS/*pem
}

function retrieve_secret_from_kv() {
  local SECRET_ID="$1"

  SECRET=$(az keyvault secret show --id "$SECRET_ID" --query value)
  echo "$SECRET"
}

function generate_boundary_config {
  log "[INFO]" "Generating $BOUNDARY_CONFIG_PATH file."

  declare -l host
  host=$(hostname -s)

  cat >$BOUNDARY_CONFIG_PATH <<EOF
disable_mlock = true

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

controller {
  name        = "$host"
  description = ""

  database {
    url = "postgresql://${boundary_database_user}:${boundary_database_password}@${boundary_database_host}/${boundary_database_name}?sslmode=require"
  }

  license = "file:///$BOUNDARY_LICENSE_PATH"
}

listener "tcp" {
  address              = "0.0.0.0:9200"
  purpose              = "api"
  tls_disable          = ${boundary_tls_disable}
  tls_cert_file        = "$BOUNDARY_DIR_TLS/cert.pem"
  tls_key_file         = "$BOUNDARY_DIR_TLS/key.pem"
%{ if boundary_tls_ca_bundle_key_vault_secret_id != "NONE" ~}
  tls_client_ca_file   = "$BOUNDARY_DIR_TLS/bundle.pem"
%{ endif }
  cors_enabled         = true
  cors_allowed_origins = ["*"]
}

listener "tcp" {
  address = "$VM_PRIVATE_IP:9201"
  purpose = "cluster"
}

listener "tcp" {
  address            = "0.0.0.0:9203"
  purpose            = "ops"
  tls_disable        = ${boundary_tls_disable}
  tls_cert_file      = "$BOUNDARY_DIR_TLS/cert.pem"
  tls_key_file       = "$BOUNDARY_DIR_TLS/key.pem"
  tls_client_ca_file = "$BOUNDARY_DIR_TLS/bundle.pem"
%{ if boundary_tls_ca_bundle_key_vault_secret_id != "NONE" ~}
  tls_client_ca_file   = "$BOUNDARY_DIR_TLS/bundle.pem"
%{ endif ~}
}

kms "azurekeyvault" {
  purpose    = "root"
  tenant_id  = "${tenant_id}"
  vault_name = "${controller_key_vault_name}"
  key_name   = "${root_key_name}"
}

kms "azurekeyvault" {
  purpose    = "recovery"
  tenant_id  = "${tenant_id}"
  vault_name = "${controller_key_vault_name}"
  key_name   = "${recovery_key_name}"
}

kms "azurekeyvault" {
  purpose    = "worker-auth"
  tenant_id  = "${tenant_id}"
  vault_name = "${worker_key_vault_name}"
  key_name   = "${worker_key_name}"
}
EOF
  chown $BOUNDARY_USER:$BOUNDARY_GROUP $BOUNDARY_CONFIG_PATH
  chmod 640 $BOUNDARY_CONFIG_PATH
}

# template_boundary_config templates out the Boundary system file
function template_boundary_systemd {
  log "[INFO]" "Templating out the Boundary service..."

  sudo bash -c "cat > $SYSTEMD_DIR/boundary.service" <<EOF
[Unit]
Description="HashiCorp Boundary"
Documentation=https://www.boundaryproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=$BOUNDARY_CONFIG_PATH
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=$BOUNDARY_USER
Group=$BOUNDARY_GROUP
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=$BOUNDARY_DIR_BIN/boundary server -config=$BOUNDARY_CONFIG_PATH
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

  # Ensure proper permissions on service file
  sudo chmod 644 $SYSTEMD_DIR/boundary.service

  log "[INFO]" "Done templating out the Boundary service."
}

function init_boundary_db {
  log "INFO" "Initializing Boundary database..."

  # Make sure to initialize the DB before starting the service. This will result in
  # a database already initialized warning if another controller has done this
  # already, making it a lazy, best effort initialization
  /usr/bin/boundary database init -skip-auth-method-creation -skip-host-resources-creation -skip-scopes-creation -skip-target-creation -config $BOUNDARY_CONFIG_PATH || true

  log "INFO" "Done initializing Boundary database."
}

# start_enable_boundary starts and enables the boundary service
function start_enable_boundary {
  log "[INFO]" "Starting and enabling the boundary service..."

  sudo systemctl enable boundary
  sudo systemctl start boundary

  log "[INFO]" "Done starting and enabling the boundary service."
}

function exit_script {
  if [[ "$1" == 0 ]]; then
    log "INFO" "boundary_custom_data script finished successfully!"
  else
    log "ERROR" "boundary_custom_data script finished with error code $1."
  fi

  exit "$1"
}

function main {
  log "INFO" "Beginning Boundary custom_data script."

  OS_ARCH=$(detect_architecture)
  log "INFO" "Detected system architecture is '$OS_ARCH'."

  OS_DISTRO=$(detect_os_distro)
  log "INFO" "Detected Linux OS distro is '$OS_DISTRO'."

  scrape_vm_info
  install_prereqs "$OS_DISTRO"
  install_azcli "$OS_DISTRO"
  user_group_create
  directory_create

  checksum_verify $OS_ARCH
  log "INFO" "Checksum verification completed for $${PRODUCT} binary."

  install_boundary_binary $OS_ARCH

  if [[ "${is_govcloud_region}" == "true" ]]; then
    log "INFO" "Setting azure-cli context to AzureUSGovernment environment."
    az cloud set --name AzureUSGovernment
  fi

  log "INFO" "Running 'az login'."
  az login --identity

  log "INFO" "Retrieving Boundary license file from Key Vault."
  retrieve_license_from_kv
  log "INFO" "Retrieving Boundary TLS certificates from Key Vault."
  retrieve_certs_from_kv
  generate_boundary_config
  template_boundary_systemd
  init_boundary_db
  start_enable_boundary

  log "INFO" "Sleeping for a minute while Boundary initializes."
  sleep 60

  log "INFO" "Polling Boundary health check endpoint until the app becomes ready..."
  while ! curl -ksfS --connect-timeout 5 https://$VM_PRIVATE_IP:9203/health; do
    sleep 5
  done

  exit_script 0
}

main
