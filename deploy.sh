# Deploy Kubernetes Cluster
#!/bin/bash

set -e

if [[ $# -lt 3 ]]; then
  echo -e "\n\tUsage: $0 <shortname>\n\n\tExample: $0 [APPLICATION] [ENVIRONMENT] [ACTION] [OPTIONS]\n"
  echo -e "\n\tUsage: $0 <shortname>\n\n\tExample: $0 webserver testing plan\n"
  echo -e "\n\tUsage: $0 <shortname>\n\n\tExample: $0 webserver testing plan -var 'variable=value'\n"
  exit 1
fi

export APPLICATION="${1}"
export ENVIRONMENT="${2}"
export SUBCOMMAND="${3}"
shift 3

BUCKET="tf-states-boostup"
VPC_STATE_PATH="v0.12/${APPLICATION}/vpc/terraform.tfstate"
APP_STATE_PATH="v0.12/${APPLICATION}/app/terraform.tfstate"
ROOT_DIR=$PWD

provision () {
    TYPE=$1 # network|application
    shift
    cd $ROOT_DIR/$TYPE
    ./terraformw ${APPLICATION} ${ENVIRONMENT} ${SUBCOMMAND} "$@"
    if [[ $? -ne 0 ]]; then
        echo -n "The $TYPE $SUBCOMMAND failed!"
        exit 1
    fi
}

show_details () {
    TYPE=$1 # network|application
    shift
    echo -e "\n\n###### Resource: $TYPE provision ########\n\n"
    echo -e "APPLICATION:          $APPLICATION"
    echo -e "ENVIRONMENT/WORKSPACE: $ENVIRONMENT"
    echo -e "ACTION:                $SUBCOMMAND"
    echo -e "ARGUMENTS:             $@"
    echo -e "\n\n##########################################\n\n"
}

if [[ $SUBCOMMAND != "destroy" ]]; then

    # Network
    show_details "network" "$@"
    provision "network" "$@"

    # Application
    show_details "application" "$@"
    provision "application" "$@"

else
    # Application
    show_details "application" "$@"
    provision "application" "$@"

    # Network
    show_details "network" "$@"
    provision "network" "$@"

    # Remove resources state file
    aws s3 rm s3://${BUCKET}/env:/${ENVIRONMENT}/${VPC_STATE_PATH}
    aws s3 rm s3://${BUCKET}/env:/${ENVIRONMENT}/${APP_STATE_PATH}
fi