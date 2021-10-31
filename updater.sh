#!/usr/bin/env bash

TIMESTAMP_FORMAT='%a %b %d %T %Y'
log() {
  echo "$(date +"${TIMESTAMP_FORMAT}") [updater] $*"
}

. /etc/bash_environment

# Turn on debugging

if [[ $DEBUG == 1 ]]; then
    set -x
fi

## Script to update the docker-compose file from the github repo via cronjob
# Get the image tag from the remote docker-compose file
# Compare with the current image tag
# if different replace it with the new one and docker-compose up -d --force-recreate

if [[ -z $PLATFORM || -z $GIT_REPO || -z $BRANCH || -z $SUB_PATH ]]; then
    log "Please define the env variables: PLATFORM, GIT_REPO, BRANCH, SUB_PATH"
    exit
fi

if [[ $PLATFORM == "github" ]]; then
    RAW_URL_PLATFORM="raw.githubusercontent.com"
else
    log "The git service $PLATFORM is not currently supported!"
    exit
fi

cd $HOME

for APP in `ls .`; do

    if [[ ! -d "$APP" ]]; then
       continue
    fi

    if [[ ! -f "$APP/docker-compose.yml" ]]; then
        continue
    fi

    # Check number of services inside the file
    N_SERVICES=$(yq e '.services | length' $APP/docker-compose.yml)

    log "Checking $APP with $N_SERVICES services"
    
    # Make list of remote and local tags
    REMOTE_TAG=($(wget -qO- https://${RAW_URL_PLATFORM}/${GIT_REPO}/${BRANCH}/${SUB_PATH}/${APP}/docker-compose.yml | yq e '(.services[].image)' -))
    log "Remote tag(s): ${REMOTE_TAG[*]}"
    LOCAL_TAG=($(yq e '(.services[].image)' $APP/docker-compose.yml))
    log "Local tag(s): ${LOCAL_TAG[*]}" 

    #Name of the service
    SERVICE_NAME=($(yq eval '(.services[] | path | .[-1])' $APP/docker-compose.yml))

    for ((i=0; i < ${#REMOTE_TAG[@]}; i++ ))
    do
        if [ ${REMOTE_TAG[$i]} != ${LOCAL_TAG[$i]} ]; then
            log "Updating local file tag with ${REMOTE_TAG[$i]}"
  
            if [ -f $APP/docker-compose.yml.1 ]; then
                rm $APP/docker-compose.yml.1
            fi
            cp $APP/docker-compose.yml $APP/docker-compose.yml.1
            
            # Replace the image with the new one
            TAG=${REMOTE_TAG[$i]} SERVICE_NAME="${SERVICE_NAME[$i]}" yq eval -i '(.services.[env(SERVICE_NAME)].image) = strenv(TAG)' $APP/docker-compose.yml
            docker-compose up -d --force-recreate -f $APP/docker-compose.yml
        else
            continue
        fi
    done
done

# Clean the images
if [[ $CLEAN_AFTER_UPDATE == "1" ]]; then
    log "Cleaning images"
    docker system prune -a --force
fi