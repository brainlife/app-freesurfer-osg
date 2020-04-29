#!/bin/bash

#return code 0 = running
#return code 1 = finished successfully
#return code 2 = failed
#return code 3 = unknown status

#pegasus-status -l work

if [ -f finished ]; then
    echo "already finished"
    exit 1
fi

if [ -f stopped ]; then
    echo "job stopped"
    exit 3
fi

pegasus-status -l work -D s > .status
jobstate=$(cat .status | tail -2  | head -1)
if [ -z "$jobstate" ]; then
	exit 2 #removed?
fi
#if [ $jobstate == "QUEUED" ]; then
#	exit 0
#fi
if [ "$jobstate" == "Running" ]; then
	cat .status | grep "Run "
	pegasus-analyzer work
	exit 0
fi
#if [ $jobstate == "DELETE PENDING" ]; then
#	exit 2
#fi
#if [ $jobstate == "DELETED" ]; then
#	exit 2
#fi
if [ "$jobstate" == "Failure" ]; then
	#TODO - pegasus reports Failure even if I stop the workflow.. (no "Stopped"?)
	pegasus-analyzer work
	exit 2
fi
if [ "$jobstate" == "COMPLETED" ]; then
	touch finished
	tar -xf subject_output.tar.bz2
	exit 1
fi

#assume failed for all other state
#'ERROR'
#'FAILED',

echo "can't determine the status!"
exit 3

