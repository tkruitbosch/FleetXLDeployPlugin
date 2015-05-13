#!/bin/bash

CONTAINERNAME=${deployed.container.name}
DEPLOYFILE=${deployed.deployable.file.name}
INSTANCES=${deployed.numberOfInstances}


echo "$(date +"%Y-%m-%d %T") INFO Load unit configuration file: $DEPLOYFILE"
if expr "$DEPLOYFILE" : '..*@\...*' > /dev/null ; then
    BASENAME=$(echo $DEPLOYFILE | sed -e 's/@.*/@/')
	eval fleetctl load $BASENAME{1..$INSTANCES}  || exit $?
else
	fleetctl load $DEPLOYFILE || exit $?
fi

echo "$(date +"%Y-%m-%d %T") INFO Fleet configuration file $DEPLOYFILE loaded."
echo "$(date +"%Y-%m-%d %T") DPL INFO done"
