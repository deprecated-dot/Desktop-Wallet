#!/bin/bash

# directories
JAVA_VERSION=11.0.1
STORAGE_DIR="${HOME}/.aion"
LOG_DIR="${STORAGE_DIR}/log"
JAVA_INSTALL="${STORAGE_DIR}/java"
JAVA_CMD="${JAVA_INSTALL}/bin/java"

CURRENT_DATE=`date '+%Y-%m-%d_%H:%M:%S'`
LOG_FILE="${LOG_DIR}/log_${CURRENT_DATE}"

mkdir -p "${LOG_DIR}"

# get the directory of the currently executing script
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "${SOURCE}" )" >/dev/null && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
echo "Located script directory: ${SCRIPT_PATH}"
cd "${SCRIPT_PATH}"

if [[ $("${JAVA_CMD}" -version 2>&1 | grep "${JAVA_VERSION}" | wc -l) -lt 1 ]]; then
  echo "Removing old local Java version: ${JAVA_INSTALL}"
  rm -rf "${JAVA_INSTALL}"
fi

if [[ ! -f "${JAVA_CMD}" ]] || [[ $("${JAVA_CMD}" -version 2>&1 | grep "${JAVA_VERSION}" | wc -l) -lt 1 ]]; then
  echo "Extracting new packaged Java version to ${STORAGE_DIR}"
  unzip java.zip -d "${STORAGE_DIR}"
fi

MOD_DIR="${SCRIPT_PATH}/mod/*"
LIB_DIR="${SCRIPT_PATH}/lib/*"

"${JAVA_CMD}" -cp "${MOD_DIR}:${LIB_DIR}" -Dlocal.storage.dir="${STORAGE_DIR}" -Xms300m -Xmx500m org.aion.wallet.WalletApplication &>> "${LOG_FILE}" &
