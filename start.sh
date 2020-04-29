#!/bin/bash

#clean up from the last run
rm -f stopped

set -x
set -e

[ -z "$FREESURFER_LICENSE" ] && echo "Please set FREESURFER_LICENSE in .bashrc" && exit 1;
echo $FREESURFER_LICENSE > license.txt

# create the site catalog from the template
export WORK_DIR=$(realpath .)
envsubst < sites.xml.template > sites.xml

cat <<EOF > run.yml
subject:
    input: $(jq -r .t1 config.json)
EOF

t2=$(jq -r .t2 config.json)
if [ $t2 != "null" ]; then
	echo "    T2: " $(jq -r .t2 config.json) >> run.yml
fi

hires=`jq -r .hires config.json`
notalcheck=`jq -r .notalcheck config.json`
cw256=`jq -r .cw256 config.json`
debug=`jq -r .debug config.json`
hippocampal=`jq -r .hippocampal config.json`

options=""
#I am not sure how we can pass the t2 path like this with freesurfer-osg
#if [ -f $t2 ]; then
#    options="$options -T2 $t2 -T2pial"
#    #https://surfer.nmr.mgh.harvard.edu/fswiki/HippocampalSubfields
#    #https://surfer.nmr.mgh.harvard.edu/fswiki/HippocampalSubfieldsAndNucleiOfAmygdala
#    if [ $hippocampal == "true" ]; then
#        options="$options -hippocampal-subfields-T1T2 $t2 t1t2"
#    fi
#else
#    if [ $hippocampal == "true" ]; then
#        options="$options -hippocampal-subfields-T1"
#    fi
#fi

if [ $hires == "true" ]; then
    options="$options -hires"
fi
if [ $notalcheck == "true" ]; then
    options="$options -notal-check"
fi
if [ $cw256 == "true" ]; then
    options="$options -cw256"
fi
if [ $debug == "true" ]; then
    options="$options -debug"
fi

if [ "$options" != "" ]; then
	echo "    autorecon-options:$options" >> run.yml
fi

echo "submitting with this this config"
cat run.yml

# generate the workflow
./workflow-generator.py --inputs-def run.yml

# make sure we also have access to the AMQP lib
export PYTHONPATH="$PYTHONPATH:/usr/lib/python2.6/site-packages"

# plan and submit the  workflow
pegasus-plan \
    --conf pegasus.conf \
    --dir $PWD \
    --relative-dir work \
    --sites condorpool \
    --output-site local \
    --dax freesurfer-osg.xml \
    --cluster horizontal \
    --submit

echo "sleeping a bit - so that status.sh works"
sleep 10

./status.sh

