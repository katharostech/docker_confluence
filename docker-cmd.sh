#!/bin/bash

trap "{ /opt/atlassian/confluence/bin/stop-confluence.sh; exit $?; }" SIGTERM SIGINT

# Run config for Confluence
/confluence-cfg.sh

# Start Confluence
su -c "/opt/atlassian/confluence/bin/start-confluence.sh -fg" confluence  &

# Loop until signal
while :
do
    sleep 4
done
