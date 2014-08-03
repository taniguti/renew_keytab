#!/bin/sh

HN=`hostname`
echo "kinit administrator"
kinit administrator
echo ""

KEYTAB=`klist -k | grep krb5.keytab | awk -F: '{print $3}'`
echo "Check current KVNO of ${KEYTAB}."
echo "----------------------------------"
CKVNO=`klist -k | grep $HN | awk '{print $1}' | head -1`
echo "KVNO is ${CKVNO} in ${KEYTAB}."
SPN=`  klist -k | grep $HN | awk '{print $2}' | head -1 | awk -F@ '{print $1}'`
KDC_KVNO=`kvno $SPN | awk -F= '{print $2}' | tr -d " "`
echo "KVNO is ${KDC_KVNO} in KDC"

if [ ${CKVNO} -eq  ${KDC_KVNO} ]; then
        echo "It's ok. Nothing to do now."
        exit 0
else
        mv ${KEYTAB} /tmp/KEYTAB.$$
        chmod 400 /tmp/KEYTAB.$$

        net ads keytab create
        chmod 644 ${KEYTAB}

        CKVNO=`klist -k | grep $HN | awk '{print $1}' | head -1`
        KDC_KVNO=`kvno $SPN | awk -F= '{print $2}' | tr -d " "`
        echo "KVNO is ${CKVNO} in ${KEYTAB}."
        echo "KVNO is ${KDC_KVNO} in KDC"
        if [ ${CKVNO} -eq  ${KDC_KVNO} ]; then
                echo "Synced OK."
                exit 0
        else
                echo "Something wrong. Hummm...."
                exit 1
        fi
fi
