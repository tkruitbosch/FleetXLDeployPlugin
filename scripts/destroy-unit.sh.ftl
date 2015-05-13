#!/bin/bash

CONTAINERNAME="${deployed.container.name}"
DEPLOYFILE=${deployed.deployable.file.name}
INSTANCES=${deployed.numberOfInstances}


echo "$(date +"%Y-%m-%d %T") INFO Destroying $INSTANCES of fleet unit: $DEPLOYFILE to $CONTAINERNAME"
if expr "$DEPLOYFILE" : '..*@\...*' > /dev/null ; then
    BASENAME=$(echo $DEPLOYFILE | sed -e 's/@.*/@/')
	eval fleetctl destroy $BASENAME{1..$INSTANCES}  || exit $?
else
	fleetctl destroy $DEPLOYFILE || exit $?
fi

echo "$(date +"%Y-%m-%d %T") INFO $INSTANCES of fleet unit $DEPLOYFILE destroyed."
echo "$(date +"%Y-%m-%d %T") DPL INFO done"
