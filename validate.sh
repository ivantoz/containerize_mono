#!/usr/bin/env bash

# A validation script for the Containerize homework.
# Run this script with no args to validate the current directory
# or optionally supply a homework directory as the first arg:
# ./validate.sh ~/dev/containerize

test_http() {
  # Check that status is 200 OK
  status_code=$(curl -k -s -o /dev/null -w %{http_code} https://localhost/ 2> /dev/null)

  if [[ $status_code == "200" ]]
  then
      echo "Pass✅: status code is ${status_code}";
  else
      echo "Fail❌: status code is ${status_code}";
  fi

  response=$(curl -k https://localhost/ 2> /dev/null)

  # Verify x-forwarded-for is in the response body and not "None"
  fwd_for=$(echo "$response" | grep -E "X-Forwarded-For: \b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b")
  if [[ "${fwd_for}" != "" ]]
  then
      echo "Pass✅: X-Forwarded-For is present and not 'None'";
  else
      echo "Fail❌: X-Forwarded-For should not be 'None'";
  fi

  # Verify x-real-ip is in the response body and not "None"
  real_ip=$(echo "$response" | grep -E "X-Real-IP: \b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b")
  if [[ "${real_ip}" != "" ]]
  then
      echo "Pass✅: X-Real-IP is present and not 'None'";
  else
      echo "Fail❌: X-Real-IP should not be 'None'";
  fi

  # Verify x-forwarded-proto is in the response body and not "None"
  fwd_proto=$(echo "$response" | grep -E "X-Forwarded-Proto: https")
  if [[ "${fwd_proto}" != "" ]]
  then
      echo "Pass✅: X-Forwarded-Proto is present and not 'None'";
  else
      echo "Fail❌: X-Forwarded-Proto should not be 'None'";
  fi

  content=$(echo "$response" | grep "You cannot be more than what you are.")
  if [[ "$content" != "" ]]
  then
    echo "Pass✅: found \"You cannot be more than what you are.\" in response"
  else
    echo "Fail❌: \"You cannot be more than what you are.\" missing from response"
  fi
}

test_local_dev() {
  # find and replace 'cannot' with 'can' in the content line to simulate local development
  sed -i.bak '/content/s/cannot/can/' app/src/index.js
  # wait few sec for reload
  sleep 1
  response=$(curl -k https://localhost/ 2> /dev/null)
  content=$(echo "$response" | grep "You can be more than what you are.")
  if [[ "$content" != "" ]]
  then
    echo "Pass✅: found \"You can be more than what you are.\" in response"
  else
    echo "Fail❌: \"You can be more than what you are.\" missing from response"
  fi
  mv app/src/index.js.bak app/src/index.js
}

function usage {
  echo "$ME: validates functionality of the current setup"
  echo "usage: $ME [-s] [DIR]"
  echo "  -s : skip SSL test"
  echo "  DIR : directory to cd into to test"
  echo ""
  echo "REALLY IMPORTANT: This script will remove the containers and images built by compose!"
  exit 0
}

ME=`basename $0`
TEST_SSL="yes"

while getopts ":sh" option
do
  case $option in
    s) TEST_SSL="no";;
    h) usage;;
  esac
done
shift $(($OPTIND - 1))

if [ -d "$1" ]
then
  cd $1
fi

# Start with clean environment
docker-compose rm -f -s 2> /dev/null
docker-compose up --build -d 2> /dev/null
echo "------------------------------------------------------------------------"
echo "| Testing SSL/TLS settings...                                          |"
echo "------------------------------------------------------------------------"
if [ "$TEST_SSL" == "yes" ]
then
  docker run -ti --rm --network="host" drwetter/testssl.sh \
        --parallel --quiet --std --protocols --headers https://localhost
else
  echo "SSL Tests skipped"
fi
echo "------------------------------------------------------------------------"
echo "| Testing HTTP header and body content...                              |"
echo "------------------------------------------------------------------------"
test_http
echo "------------------------------------------------------------------------"
echo "| Testing hot reload for local development...                          |"
echo "------------------------------------------------------------------------"
test_local_dev
echo "------------------------------------------------------------------------"
echo "| Docker image sizes:                                                  |"
echo "------------------------------------------------------------------------"
docker images containerize_app --format "{{.Repository}}:{{.Tag}} {{.Size}}"
docker images containerize_nginx --format "{{.Repository}}:{{.Tag}} {{.Size}}"


# Clean up environment when done
docker-compose rm -f -s  2> /dev/null
docker-compose down --rmi all 2> /dev/null
