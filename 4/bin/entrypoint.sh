#!/bin/bash

set -euo pipefail

declare -a args=()

add_env_var_as_env_prop() {
  if [ "$1" ]; then
    args+=("-D$2=$1")
  fi
}

# if nothing is passed, assume we want to run sonar-scanner
if [ "$#" == 0 ]; then
  set -- sonar-scanner
fi

# if first arg looks like a flag, assume we want to run sonar-scanner with flags
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- sonar-scanner "$@"
fi

if [[ "$1" = 'sonar-scanner' ]]; then
  if [[ ! -r "${SONAR_USER_HOME}" ]] || [[ ! -w "${SONAR_USER_HOME}" ]]; then
    echo "Cannot read from or write to '${SONAR_USER_HOME}'. Please make sure appropriate permissions for this volume are set."
    exit 1
  fi

  if [[ ! -r "${PWD}" ]] || [[ ! -w "${PWD}" ]]; then
    echo "Cannot read from or write to '${PWD}'. Please make sure appropriate permissions are set for volumes used."
    exit 1
  fi

  add_env_var_as_env_prop "${SONAR_LOGIN:-}" "sonar.login"
  add_env_var_as_env_prop "${SONAR_PASSWORD:-}" "sonar.password"
  add_env_var_as_env_prop "${SONAR_PROJECT_BASE_DIR:-}" "sonar.projectBaseDir"
  if [ ${#args[@]} -ne 0 ]; then
    set -- sonar-scanner "${args[@]}" "${@:2}"
  fi
fi

exec "$@"
