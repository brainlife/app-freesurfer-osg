#!/bin/bash

#return code 0 = running
#return code 1 = finished successfully
#return code 2 = failed
#return code 3 = unknown status

if [ -f finished ]; then
    echo "already finished"
    exit 1
fi

if [ -f stopped ]; then
    echo "job stopped"
    exit 3
fi

pegasus-status -l work -D s > .status || exit 3

jobstate=$(cat .status | tail -2  | head -1)
if [ -z "$jobstate" ]; then
	exit 2 #removed?
fi
if [ "$jobstate" == "Running" ]; then
	cat .status | grep "Run "
	pegasus-analyzer work | tail -n +4
	exit 0
fi
if [ "$jobstate" == "Failure" ]; then
	#TODO - pegasus reports Failure even if I stop the workflow.. (no "Stopped"?)
	pegasus-analyzer work | tail -n +4
	exit 2
fi
if [ "$jobstate" == "Success" ]; then
	touch finished
	tar -xf output_output.tar.bz2
	rm output_output.tar.bz2
	mkdir -p freesurfer
	mv output freesurfer
	exit 1
fi
echo "can't determine the status! $jobstate"
exit 3

