#!/usr/bin/env bash

max_recorded_count=$((${DRAIN_AFTER_SESSION_COUNT:-SE_DRAIN_AFTER_SESSION_COUNT}))
recorded_count=0
last_session_id=""

function get_session_id {
    session_id=$(curl -s --request GET 'http://'${DISPLAY_CONTAINER_NAME}':'${SE_NODE_PORT}'/status' | jq -r '.[]?.node?.slots | .[0]?.session?.sessionId')
}

function capture_session() {
    if [ ! -d ${SE_SESSION_FOLDER} ];
    then
        mkdir -p ${SE_SESSION_FOLDER}
    fi
    echo "${POD_NAME}" > ${SE_SESSION_FOLDER}'/'$session_id'.txt'
    cat ${SE_SESSION_FOLDER}'/'$session_id'.txt'
    last_session_id=$session_id
    recorded_count=$((recorded_count+1))
}

function terminate_gracefully {
    echo "Trapped SIGTERM/SIGINT/x so shutting down the listener..."
    while true;
    	do
    		get_session_id
        if [ "$session_id" != "null" -a "$session_id" != "" ];
        then
            echo "Session: $session_id is active, waiting for it to finish"
            sleep 2
        else
            break
        fi
    done
    echo "Shutdown completed!"
    exit 0
}

trap terminate_gracefully SIGTERM SIGINT

while true;
do
  get_session_id
  if [ "$session_id" != "null" -a "$session_id" != "" ] && [ "$last_session_id" != "$session_id" ];
  then
    capture_session
  else
    sleep 2
  fi
done
