#!/bin/bash
# Used by travis pipeline to run the test and compile wheel packages
# This script is not intended to be used outside travis.
set -e
set -x

# TODO REMOVE THIS
PLAT=manylinux2010_x86_64
PYBIN=/opt/python/cp37-cp37m/bin

# Install a system package required by our library
yum install -y wget libacl-devel librsync-devel rdiff rsync

# Download testfiles
useradd -ms /bin/bash testuser
chown -R testuser:testuser /rdiff-backup/
wget -O rdiff-backup_testfiles.tar.gz https://github.com/ericzolf/rdiff-backup/releases/download/Testfiles2019-08-10/rdiff-backup_testfiles_2019-08-10.tar.gz
tar -xvf rdiff-backup_testfiles.tar.gz
bash -x ./rdiff-backup_testfiles.fix.sh testuser testuser

# Run tox test as non-root user
"${PYBIN}/pip" install tox flake8
cd /rdiff-backup/
su testuser -c "${PYBIN}/tox"

# Compile wheels
"${PYBIN}/pip" wheel /rdiff-backup/ -w wheelhouse/

# Bundle external shared libraries into the wheels
auditwheel repair wheelhouse/*.whl --plat $PLAT -w /rdiff-backup/wheelhouse/
