#!/usr/bin/env bash

VIDEO_SIZE="${SE_SCREEN_WIDTH}""x""${SE_SCREEN_HEIGHT}"
DISPLAY_CONTAINER_NAME=${DISPLAY_CONTAINER_NAME}
DISPLAY_NUM=${DISPLAY_NUM}
FILE_NAME=${FILE_NAME}
FRAME_RATE=${FRAME_RATE:-$SE_FRAME_RATE}
CODEC=${CODEC:-$SE_CODEC}
PRESET=${PRESET:-$SE_PRESET}

function get_session_id {
    session_id=$(curl -s --request GET 'http://'${DISPLAY_CONTAINER_NAME}':'${SE_NODE_PORT}'/status' | jq -r '.[]?.node?.slots | .[0]?.session?.sessionId')
}

function star_recording {
    video_file_name="${SE_VIDEO_FOLDER}/$session_id.mp4"
    ffmpeg -nostdin -y -f x11grab -video_size ${VIDEO_SIZE} -r ${FRAME_RATE} -i ${DISPLAY_CONTAINER_NAME}:${DISPLAY_NUM}.0 -codec:v ${CODEC} ${PRESET} -pix_fmt yuv420p $video_file_name &
    FFMPEG_PID=$!
    recording_started="true"
}

function stop_recording {
    kill -s SIGINT ${FFMPEG_PID}
    wait ${FFMPEG_PID}
    recording_started="false"
    recorded_count=$((recorded_count+1))
}

function terminate_gracefully {
    echo "Trapped SIGTERM/SIGINT/x so shutting down video-recording..."
    while true;
    	do
    		get_session_id
        if [ "$session_id" != "null" -a "$session_id" != "" ] && [ $recording_started = "true" ];
        then
            echo "Session: $session_id is active, waiting for it to finish"
            sleep 1
        else
            pkill --signal TERM -f "ffmpeg"
            break
        fi
    done
    pkill --signal TERM -f "video_ready.py"
    echo "Shutdown completed!"
}

if [ "${SE_VIDEO_RECORD}" = "true" ];
then
  max_recorded_count=$((${DRAIN_AFTER_SESSION_COUNT:-SE_DRAIN_AFTER_SESSION_COUNT}))
  recorded_count=0
	return_code=1
	max_attempts=50
	attempts=0
	recording_started="false"
	video_file_name=""

	trap terminate_gracefully SIGTERM SIGINT

	echo 'Checking if the display is open...'
	until [ $return_code -eq 0 -o $attempts -eq $max_attempts ]; do
		xset -display ${DISPLAY_CONTAINER_NAME}:${DISPLAY_NUM} b off > /dev/null 2>&1
		return_code=$?
		if [ $return_code -ne 0 ]; then
			echo 'Waiting before next display check...'
			sleep 0.5
		fi
		attempts=$((attempts+1))
	done

	while true;
	do
		get_session_id
		if [ "$session_id" != "null" -a "$session_id" != "" ] && [ $recording_started = "false" ];
		then
		  echo "Reached session: $session_id"
			echo "Starting to record video"
			star_recording
			echo "Video recording started"
		elif [ "$session_id" = "null" -o "$session_id" = "" ] && [ $recording_started = "true" ];
		then
			echo "Stopping to record video"
			stop_recording
			echo "Video recording stopped"
			if [ $max_recorded_count -gt 0 ] && [ $recorded_count -ge $max_recorded_count ];
      then
        echo "Max recorded count reached, exiting"
        exit 0
      fi
		elif [ $recording_started = "true" ];
		then
			echo "Video recording in progress"
		fi
		sleep 1
	done
fi
