#!/bin/bash

RPM_FULL_PATH=$1
BIN_TO_PROTECT=$2
FEATURE_ID=$3

RPM_DIR=`dirname $RPM_FULL_PATH`
RPM_FILE=`basename $RPM_FULL_PATH`
echo "RPM_FULL_PATH  : $RPM_FULL_PATH"
echo "RPM_FILE       : $RPM_FILE"
echo "RPM_DIR        : $RPM_DIR"
echo "BIN_TO_PROTECT : $BIN_TO_PROTECT"
echo "FEATURE_ID     : $FEATURE_ID"

RPM_TYPE=`ls ${RPM_FILE} | awk -F '.rpm' '{print $1}'`
REBUILD_DIR="/root/rpmbuild/"
REBUILD_ROOT="${REBUILD_DIR}BUILDROOT/${RPM_TYPE}"
REBUILD_SPECS="${REBUILD_DIR}SPECS/app.spec"
REBUILD_UNPROTECT_BIN="${REBUILD_ROOT}${BIN_TO_PROTECT}"
REBUILD_PROTECT_BIN="${REBUILD_UNPROTECT_BIN}_protected"

rm -rf ${REBUILD_DIR}
mkdir -p ${REBUILD_DIR}SPECS/
mkdir -p ${REBUILD_ROOT}
rpmrebuild -s ${REBUILD_SPECS} -p $RPM_FULL_PATH
cd ${REBUILD_ROOT}
rpm2cpio ${RPM_FULL_PATH} | cpio -dium

/opt/Sentinel/Linux/VendorTools/Envelope/linuxenv -v:/opt/VendorCodes/GEEDGE.hvc -f:$FEATURE_ID --msg-out:4 --debug --memdump --randomize:1 ${REBUILD_UNPROTECT_BIN} ${REBUILD_PROTECT_BIN}
echo "Envelope Bin: `md5sum ${REBUILD_PROTECT_BIN}`"
mv ${REBUILD_PROTECT_BIN} ${REBUILD_UNPROTECT_BIN}
rpmbuild -bb ${REBUILD_SPECS}

mv ${REBUILD_DIR}RPMS/x86_64/${RPM_FILE} ${RPM_DIR}/envelope-${RPM_FILE}
echo "Envelope RPM: ${RPM_DIR}/envelope-${RPM_FILE}"
