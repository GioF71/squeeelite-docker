#!/bin/bash

echo "=== BEGIN Available audio devices ==="
/usr/bin/squeezelite -l
echo "=== END-- Available audio devices ==="
echo ""

# load presets
echo "=== BEGIN Loading presets ==="
source run-presets.sh
echo "=== END-- Loading presets ==="

CMD_LINE="/usr/bin/squeezelite"
echo "Initializing command line: ["$CMD_LINE"]"

if [ -z "${PRESET}" ]; then
  echo "No presets have been specified";
else
  echo "Presets have been specified: ["$PRESET"]";
  echo "Explicitly set properties will not be overridden"
  echo "Presets are executed in order of appearance"
  echo "Current SQUEEZELITE_AUDIO_DEVICE = $SQUEEZELITE_AUDIO_DEVICE"
  echo "Current SQUEEZELITE_RATES = $SQUEEZELITE_RATES"
  echo "Current SQUEEZELITE_UPSAMPLING = $SQUEEZELITE_UPSAMPLING"

  OLD_IFS=$IFS
  IFS=',';
  read -rasplitIFS<<< "$PRESET";
  IFS=$OLD_IFS

  current_key=""
  current_value=""
  for current_preset in "${splitIFS[@]}"; do
    if ! [ -z "${current_preset}" ]; then
      echo "Processing current preset: ["$current_preset"]";
      # device in preset
      if [[ -z "${SQUEEZELITE_AUDIO_DEVICE}" || "${SQUEEZELITE_AUDIO_DEVICE}" == "default" ]]; then
        current_key=$current_preset".device"
        current_value=${presets[${current_key}]}
        if [[ -v current_value ]]; then
          echo "Setting SQUEEZELITE_AUDIO_DEVICE to ["$current_value"]"
          SQUEEZELITE_AUDIO_DEVICE=$current_value
        else
          echo "Key ["$current_key"] not found"
        fi
      else
        echo "SQUEEZELITE_AUDIO_DEVICE already set to ["$SQUEEZELITE_AUDIO_DEVICE"]"
      fi
      # rates in preset
      if [[ -z "${SQUEEZELITE_RATES}" || "${SQUEEZELITE_RATES}" == "" ]]; then
        current_key=$current_preset".rates"
        current_value=${presets[${current_key}]}
        if [[ -v current_value ]]; then
          current_value=${presets[${current_key}]}
          echo "Setting SQUEEZELITE_RATES to ["$current_value"]"
          SQUEEZELITE_RATES=$current_value
        else
          echo "Key ["$current_key"] not found"
        fi
      else
        echo "SQUEEZELITE_RATES already set to ["$SQUEEZELITE_RATES"]"
      fi
      # upsampling in preset
      if [[ -z "${SQUEEZELITE_UPSAMPLING}" || "${SQUEEZELITE_UPSAMPLING}" == "" ]]; then
        current_key=$current_preset".upsampling"
        current_value=${presets[${current_key}]}
        if [[ -v current_value ]]; then
          current_value=${presets[${current_key}]}
          echo "Setting SQUEEZELITE_UPSAMPLING to ["$current_value"]"
          SQUEEZELITE_UPSAMPLING=$current_value
        else
          echo "Key ["$current_key"] not found"
        fi
      else
        echo "SQUEEZELITE_UPSAMPLING already set to ["$SQUEEZELITE_UPSAMPLING"]"
      fi
      # codecs in preset
      if [[ -z "${SQUEEZELITE_CODECS}" || "${SQUEEZELITE_CODECS}" == "" ]]; then
        current_key=$current_preset".codecs"
        current_value=${presets[${current_key}]}
        if [[ -v current_value ]]; then
          current_value=${presets[${current_key}]}
          echo "Setting SQUEEZELITE_CODECS to ["$current_value"]"
          SQUEEZELITE_CODECS=$current_value
        else
          echo "Key ["$current_key"] not found"
        fi
      else
        echo "SQUEEZELITE_CODECS already set to ["$SQUEEZELITE_CODECS"]"
      fi
      # exclude codecs in preset
      if [[ -z "${SQUEEZELITE_EXCLUDE_CODECS}" || "${SQUEEZELITE_EXCLUDE_CODECS}" == "" ]]; then
        current_key=$current_preset".exclude-codecs"
        current_value=${presets[${current_key}]}
        if [[ -v current_value ]]; then
          current_value=${presets[${current_key}]}
          echo "Setting SQUEEZELITE_EXCLUDE_CODECS to ["$current_value"]"
          SQUEEZELITE_EXCLUDE_CODECS=$current_value
        else
          echo "Key ["$current_key"] not found"
        fi
      else
        echo "SQUEEZELITE_EXCLUDE_CODECS already set to ["$SQUEEZELITE_EXCLUDE_CODECS"]"
      fi
    fi
  done;
  # summary of preset values
  echo "Final SQUEEZELITE_AUDIO_DEVICE = $SQUEEZELITE_AUDIO_DEVICE"
  echo "Final SQUEEZELITE_RATES = $SQUEEZELITE_RATES"
  echo "Final SQUEEZELITE_UPSAMPLING = $SQUEEZELITE_UPSAMPLING"
  echo "Final SQUEEZELITE_CODECS = $SQUEEZELITE_CODECS"
  echo "Final SQUEEZELITE_EXCLUDE_CODECS = $SQUEEZELITE_EXCLUDE_CODECS"
fi

if [ -z "${SQUEEZELITE_AUDIO_DEVICE}" ]; then
  echo "Variable SQUEEZELITE_AUDIO_DEVICE has not been specified";
else
  echo "Variable SQUEEZELITE_AUDIO_DEVICE has been specified: $SQUEEZELITE_AUDIO_DEVICE";
  CMD_LINE="$CMD_LINE -o "$SQUEEZELITE_AUDIO_DEVICE;
fi

if [ -z "${SQUEEZELITE_MIXER_DEVICE}" ]; then
  echo "Variable SQUEEZELITE_MIXER_DEVICE has not been specified";
else
  echo "Variable SQUEEZELITE_MIXER_DEVICE has been specified: $SQUEEZELITE_MIXER_DEVICE";
  CMD_LINE="$CMD_LINE -O $SQUEEZELITE_MIXER_DEVICE";
fi

if [ -z "${SQUEEZELITE_MAC_ADDRESS}" ]; then
  echo "Variable SQUEEZELITE_MAC_ADDRESS not specified";
else
  echo "Variable SQUEEZELITE_MAC_ADDRESS specified: $SQUEEZELITE_MAC_ADDRESS";
  CMD_LINE="$CMD_LINE -m $SQUEEZELITE_MAC_ADDRESS";
fi

if [ -z "${SQUEEZELITE_NAME}" ]; then
  echo "Variable SQUEEZELITE_NAME has not been specified";
else
  echo "Variable SQUEEZELITE_NAME has been specified: $SQUEEZELITE_NAME";
  CMD_LINE="$CMD_LINE -n $SQUEEZELITE_NAME";
fi

if [ -z "${SQUEEZELITE_MODEL_NAME}" ]; then
  echo "Variable SQUEEZELITE_MODEL_NAME has not been specified";
else
  echo "Variable SQUEEZELITE_MODEL_NAME has been specified: $SQUEEZELITE_MODEL_NAME";
  CMD_LINE="$CMD_LINE -M $SQUEEZELITE_MODEL_NAME";
fi

if [ -z "${SQUEEZELITE_TIMEOUT}" ]; then
  echo "Variable SQUEEZELITE_TIMEOUT has not been specified, using default $DEFAULT_SQUEEZELITE_TIMEOUT";
  SQUEEZELITE_TIMEOUT=$DEFAULT_SQUEEZELITE_TIMEOUT;
else
  echo "Variable SQUEEZELITE_TIMEOUT has been specified: $SQUEEZELITE_TIMEOUT";
  CMD_LINE="$CMD_LINE -C $SQUEEZELITE_TIMEOUT";
fi
CMD_LINE="$CMD_LINE -C $SQUEEZELITE_TIMEOUT";

if [ -z "${SQUEEZELITE_DELAY}" ]; then
  echo "Variable SQUEEZELITE_DELAY has not been specified, using default $DEFAULT_SQUEEZELITE_DELAY";
  SQUEEZELITE_DELAY=$DEFAULT_SQUEEZELITE_DELAY;
else
  echo "Variable SQUEEZELITE_DELAY has been specified: $SQUEEZELITE_DELAY";
fi
CMD_LINE="$CMD_LINE -D $SQUEEZELITE_DELAY";

if [ -z "${SQUEEZELITE_SERVER_PORT}" ]; then
  echo "Variable SQUEEZELITE_SERVER_PORT has not been specified, using discovery";
else
  echo "Variable SQUEEZELITE_SERVER_PORT has been specified: $SQUEEZELITE_SERVER_PORT";
  CMD_LINE="$CMD_LINE -s $SQUEEZELITE_SERVER_PORT";
fi

if [ -z "${SQUEEZELITE_PARAMS}" ]; then
  echo "Variable SQUEEZELITE_PARAMS has not been specified";
else
  echo "Variable SQUEEZELITE_PARAMS has been specified: $SQUEEZELITE_PARAMS";
  CMD_LINE="$CMD_LINE -a $SQUEEZELITE_PARAMS";
fi

if [ -z "${SQUEEZELITE_CODECS}" ]; then
  echo "Variable SQUEEZELITE_CODECS has not been specified";
else
  echo "Variable SQUEEZELITE_CODECS has been specified: $SQUEEZELITE_CODECS";
  CMD_LINE="$CMD_LINE -c $SQUEEZELITE_CODECS";
fi

if [ -z "${SQUEEZELITE_EXCLUDE_CODECS}" ]; then
  echo "Variable SQUEEZELITE_EXCLUDE_CODECS has not been specified";
else
  echo "Variable SQUEEZELITE_EXCLUDE_CODECS has been specified: $SQUEEZELITE_EXCLUDE_CODECS";
  CMD_LINE="$CMD_LINE -e $SQUEEZELITE_EXCLUDE_CODECS";
fi

if [ -z "${SQUEEZELITE_PRIORITY}" ]; then
  echo "Variable SQUEEZELITE_PRIORITY has not been specified";
else
  echo "Variable SQUEEZELITE_PRIORITY has been specified: $SQUEEZELITE_PRIORITY";
  CMD_LINE="$CMD_LINE -p $SQUEEZELITE_PRIORITY";
fi

if [ -z "${SQUEEZELITE_RATES}" ]; then
  echo "Variable SQUEEZELITE_RATES not specified";
else
  echo "Variable SQUEEZELITE_RATES specified: $SQUEEZELITE_RATES";
  CMD_LINE="$CMD_LINE -r $SQUEEZELITE_RATES";
fi

if [ -z "${SQUEEZELITE_UPSAMPLING}" ]; then
  echo "Variable SQUEEZELITE_UPSAMPLING not specified";
else
  echo "Variable SQUEEZELITE_UPSAMPLING specified: $SQUEEZELITE_UPSAMPLING";
  CMD_LINE="$CMD_LINE -R $SQUEEZELITE_UPSAMPLING";
fi

if [ -z "${SQUEEZELITE_BUFFER_SIZE}" ]; then
  echo "Variable SQUEEZELITE_BUFFER_SIZE not specified";
  if [ -z "${SQUEEZELITE_STREAM_AND_OUTPUT_BUFFER_SIZE}" ]; then
    echo "Variable SQUEEZELITE_STREAM_AND_OUTPUT_BUFFER_SIZE (DEPRECATED) not specified";
  else
    echo "Variable SQUEEZELITE_STREAM_AND_OUTPUT_BUFFER_SIZE (DEPRECATED) specified: $SQUEEZELITE_STREAM_AND_OUTPUT_BUFFER_SIZE";
    CMD_LINE="$CMD_LINE -b $SQUEEZELITE_STREAM_AND_OUTPUT_BUFFER_SIZE";
  fi
else
  echo "Variable SQUEEZELITE_BUFFER_SIZE specified: $SQUEEZELITE_BUFFER_SIZE";
  CMD_LINE="$CMD_LINE -b $SQUEEZELITE_BUFFER_SIZE";
fi

if [ -z "${SQUEEZELITE_UNMUTE}" ]; then
  echo "Variable SQUEEZELITE_UNMUTE not specified";
else
  echo "Variable SQUEEZELITE_UNMUTE specified: $SQUEEZELITE_UNMUTE";
  CMD_LINE="$CMD_LINE -U $SQUEEZELITE_UNMUTE";
fi

if [ -z "${SQUEEZELITE_VOLUME_CONTROL}" ]; then
  echo "Variable SQUEEZELITE_VOLUME_CONTROL not specified";
else
  echo "Variable SQUEEZELITE_VOLUME_CONTROL specified: $SQUEEZELITE_VOLUME_CONTROL";
  CMD_LINE="$CMD_LINE -V $SQUEEZELITE_VOLUME_CONTROL";
fi

if [ -z "${SQUEEZELITE_LINEAR_VOLUME}" ]; then
  echo "Variable SQUEEZELITE_LINEAR_VOLUME not specified";
else
  echo "Variable SQUEEZELITE_LINEAR_VOLUME specified: $SQUEEZELITE_LINEAR_VOLUME";
  linear=${SQUEEZELITE_LINEAR_VOLUME^^}
  echo "linear: $linear";
  if [ "$linear" == "Y" ]; then
    echo "Variable SQUEEZELITE_LINEAR_VOLUME set to enabled.";
    CMD_LINE="$CMD_LINE -X";
  else 
    if [ "$linear" == "N" ]; then
      echo "Variable SQUEEZELITE_LINEAR_VOLUME set to disabled.";
    else
      echo "Variable SQUEEZELITE_LINEAR_VOLUME invalid value: $SQUEEZELITE_LINEAR_VOLUME";
    fi
  fi
fi

if [ -z "${SQUEEZELITE_VISUALIZER}" ]; then
  echo "Variable SQUEEZELITE_VISUALIZER not specified";
else
  echo "Variable SQUEEZELITE_VISUALIZER specified: $SQUEEZELITE_VISUALIZER";
  visualizer=${SQUEEZELITE_VISUALIZER^^}
  echo "visualizer: $visualizer";
  if [ "$visualizer" == "Y" ]; then
    echo "Variable SQUEEZELITE_VISUALIZER set to enabled.";
    CMD_LINE="$CMD_LINE -v";
  else 
    if [ "$visualizer" == "N" ]; then
      echo "Variable SQUEEZELITE_VISUALIZER set to disabled.";
    else
      echo "Variable SQUEEZELITE_VISUALIZER invalid value: $SQUEEZELITE_VISUALIZER";
    fi
  fi
fi

echo "Command Line: ["$CMD_LINE"]"
eval $CMD_LINE