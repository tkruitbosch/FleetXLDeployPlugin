#!/bin/bash

CONTAINERNAME="${deployed.container.name}"
DEPLOYFILE=${deployed.deployable.file.name}
INSTANCES=${deployed.numberOfInstances}


echo "$(date +"%Y-%m-%d %T") INFO Submitting fleet configuration file: $DEPLOYFILE to $CONTAINERNAME"
fleetctl submit $DEPLOYFILE || exit $?

echo "$(date +"%Y-%m-%d %T") INFO Fleet configuration file $DEPLOYFILE submitted."
echo "$(date +"%Y-%m-%d %T") DPL INFO done"
