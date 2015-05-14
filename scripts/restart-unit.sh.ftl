#!/bin/bash

CONTAINERNAME="${deployed.container.name}"
DEPLOYFILE=${deployed.deployable.file.name}
INSTANCES=${deployed.numberOfInstances}

function get_state() {
	fleetctl list-units -fields=unit,sub -no-legend | grep "^$1" | cut -f2
}

function wait_until_unit_is_gone() {
	wait_until_state $1 '^$'
}

function wait_until_state() {
	local OLDSTATE=""
        local STATE=$(get_state $1)
        while ! (echo $STATE | egrep -q "$2"); do
		if [ "$STATE" != "$OLDSTATE" ] ; then
			test -n "$OLDSTATE" && echo
			echo  -n "$unit in state $STATE";
		else
			echo -n .
		fi
                sleep 1;
		OLDSTATE=$STATE
                STATE=$(get_state $1)
        done
	test -n "$OLDSTATE" && echo
	test -z "$STATE" && STATE="removed"
	echo  "$unit in state $STATE.";
}

function start_unit() {
	echo -n "Start u $1";
    fleetctl load $1
    fleetctl start $1
	wait_until_state $1 "running"
}

function restart_unit() {
	echo -n "restart u $1";
	STATE=$(get_state $1)
    if [[ $STATE == "running" ]] ; then
		fleetctl stop $1
		wait_until_state $1 "failed|dead"
	fi
	fleetctl destroy $1
	wait_until_unit_is_gone $1
    start_unit $1
}

function list_all_active_units() {
    pattern=$(echo $1 | sed -e 's/@.service$/@[0-9][0-9]*.service/g')
	fleetctl list-units -fields=unit | egrep -e "$pattern"
}

function list_all_inactive_unit_files() {
    pattern=$(echo $1 | sed -e 's/@.service$/@[0-9][0-9]*.service/g')
	fleetctl list-unit-files -fields=unit,state | grep "$pattern" | grep inactive | cut -f1
}

function restart_all_active_units() {
	for unit in $(list_all_active_units $1); do
		restart_unit $unit
	done
}

function start_all_inactive_units() {
    for unit in $(list_all_inactive_unit_files $1); do
		fleetctl destroy $unit
		start_unit $unit
	done
}

function list_all_units() {
    pattern=$(echo $1 | sed -e 's/@.service$/@[0-9][0-9]*.service/g')
	fleetctl list-units -fields=unit | egrep -e "$pattern"
}

function restart_all_active_units() {
    for unit in $(list_all_active_units $1); do
		restart_unit $unit
	done
}

echo "$(date +"%Y-%m-%d %T") INFO Restarting unit: $DEPLOYFILE on cluster container $CONTAINERNAME"
restart_all_active_units $DEPLOYFILE
if [ $? != 0 ] ; then
	exit $?
fi
start_all_inactive_units $DEPLOYFILE || exit $?

echo "$(date +"%Y-%m-%d %T") INFO Fleet configuration file $DEPLOYFILE restarted."
echo "$(date +"%Y-%m-%d %T") DPL INFO done"
