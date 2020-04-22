#!/bin/bash

pegasus-remove work 
ret=$?
if [ ! $ret -eq 0 ]; then
	echo "failed to stop"
	exit $ret
fi

touch stopped
