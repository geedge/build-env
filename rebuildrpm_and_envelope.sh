#!/bin/bash

RPM_FULL_PATH=$1
BIN_TO_PROTECT_IN_RPM=$2
FEATURE_ID=$3
APP_NAME_IN_RPM_SPEC=$4

RPM_DIR=`dirname $RPM_FULL_PATH`
RPM_FILE=`basename $RPM_FULL_PATH`
echo "RPM_FULL_PATH            : $RPM_FULL_PATH"
echo "RPM_FILE                 : $RPM_FILE"
echo "RPM_DIR                  : $RPM_DIR"
echo "FEATURE_ID               : $FEATURE_ID"
echo "BIN_TO_PROTECT_IN_RPM    : $BIN_TO_PROTECT_IN_RPM"
echo "APP_NAME_IN_RPM_SPEC     : $APP_NAME_IN_RPM_SPEC"

# Get the prefix of the new rpm file name
RPM_PREFIX=`echo ${RPM_FILE} | awk -F '.rpm' '{print $1}' | awk -F ${APP_NAME_IN_RPM_SPEC} '{print "'${APP_NAME_IN_RPM_SPEC}'-pr" $2}'`

RPM_REBUILD_DIR="/root/rpmbuild/"
RPM_REBUILD_ROOT="${RPM_REBUILD_DIR}BUILDROOT/${RPM_PREFIX}"
RPM_REBUILD_SPECS="${RPM_REBUILD_DIR}SPECS/app.spec"
UNPROTECT_BIN="${RPM_REBUILD_ROOT}${BIN_TO_PROTECT_IN_RPM}"
PROTECT_BIN="${UNPROTECT_BIN}_protected"

rm -rf ${RPM_REBUILD_DIR}
mkdir -p ${RPM_REBUILD_DIR}SPECS/
mkdir -p ${RPM_REBUILD_ROOT}

# Get specification file from rpm
rpmrebuild -s ${RPM_REBUILD_SPECS} -p $RPM_FULL_PATH

# Unzip files from rpm
cd ${RPM_REBUILD_ROOT}
rpm2cpio ${RPM_FULL_PATH} | cpio -dium

# Envelope
/opt/Sentinel/Linux/VendorTools/Envelope/linuxenv -v:/opt/VendorCodes/GEEDGE.hvc -f:$FEATURE_ID --msg-out:4 --randomize:1 ${UNPROTECT_BIN} ${PROTECT_BIN}
echo "Envelope Bin: `md5sum ${PROTECT_BIN}`"
mv ${PROTECT_BIN} ${UNPROTECT_BIN}

# Update specification file, and rebuild rpm
sed -i "s/Name:[ ][ ]*${APP_NAME_IN_RPM_SPEC}/Name:          ${APP_NAME_IN_RPM_SPEC}-pr/g" ${RPM_REBUILD_SPECS}
rpmbuild -bb ${RPM_REBUILD_SPECS}

# Move the new rpm package to the path of the original rpm package
NEW_RPM=`echo ${RPM_FILE} | awk -F ${APP_NAME_IN_RPM_SPEC} '{print "'${APP_NAME_IN_RPM_SPEC}'-pr" $2}'`
mv ${RPM_REBUILD_DIR}RPMS/x86_64/${NEW_RPM} ${RPM_DIR}/${NEW_RPM}

echo "=== After Envelope ==="
ls -ahl ${RPM_DIR}/*.rpm