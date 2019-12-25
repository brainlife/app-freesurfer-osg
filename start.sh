#!/bin/bash

set -x
set -e

echo $FREESURFER_LICENSE > license.txt

# create the site catalog from the template
envsubst < sites.xml.template > sites.xml

cat <<EOF > run.yml
subject:
    input: $(jq -r .t1 config.json)
EOF

t2=$(jq -r .t2 config.json)
if [ $t2 != "null" ]; then
	echo "    T2: " $(jq -r .t2 config.json) >> run.yml
fi

#TODO - expose options
options="" 
if [ $options != "" ]; then
	echo "    autorecon-options: $options" >> run.yml
fi

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
