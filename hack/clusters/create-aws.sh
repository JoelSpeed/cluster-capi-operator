#!/bin/bash

function printcolor {
  COLOR='\033[0;32m'
  NC='\033[0m'
  printf "${COLOR}$1${NC}\n"
}

printcolor "Getting required variables"
export CLUSTER_NAME=$(kubectl get infrastructure cluster -o jsonpath="{.status.infrastructureName}")
export AWS_REGION=$(kubectl get machineset.machine.openshift.io -n openshift-machine-api -o jsonpath="{.items[0].spec.template.spec.providerSpec.value.placement.region}")
export INFRASTRUCTURE_KIND=AWSCluster
export CLUSTER_CONTROLPLANE_ENDPOINT=$(kubectl get infrastructure cluster -o jsonpath="{.status.apiServerInternalURI}" | sed -E "s|https?://(.*)$|\1|g")
export CLUSTER_CONTROLPLANE_HOST=$(echo ${CLUSTER_CONTROLPLANE_ENDPOINT} | cut -d':' -f1)
export CLUSTER_CONTROLPLANE_PORT=$(echo ${CLUSTER_CONTROLPLANE_ENDPOINT} | cut -d':' -f2)

printcolor "Creating AWS infrastructure cluster"
envsubst <hack/clusters/templates/aws.yaml | kubectl apply -f -

printcolor "Creating core cluster"
envsubst <hack/clusters/templates/core.yaml | kubectl apply -f -

printcolor "Done"
