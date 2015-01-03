#!/bin/bash

################################################################################
#
# STEP 1:
# -------
# - Run this file from src directory
#
# STEP 2:
# -------
# - In WingIDE make sure salt-call.py is set as 'Main Debug File'
#     Project -> Add Existing Directory ... /srv/salt-formulas
#     Project -> Project Properties -> Debug/Execute -> Main Entry Point -> /srv/salt-formulas/yamlscript-formula/src/salt-call
# - In salt-call.py make sure SYNC=False
#
# STEP 3:
# -------
# - In WingIDE, set debug environment
#     To display yaml output without running a highstate (state.show.sls)
#     Debug -> Debug Environment -> Environment --> --local --out=yaml state.show_sls users-test
# - Or just run a highstate
#     Debug -> Debug Environment -> Environment --> --local state.highstate -l debug
#
# STEP 4:
# -------
# - Set breakpoint in src directory
#   not in:  /var/cache/salt/minion/extmods/...
#
################################################################################

GITFS=/srv/salt/salt/files/master.d/gitfs.conf

CACHE_DIR=/var/cache/salt/minion
EXTMODS="${CACHE_DIR}/extmods"

SRC="$(readlink -m .)"
FORMULA_DIR="$(readlink -m ..)"
NOW=$(date +"%Y-%m-%d:%H-%M-%S")

#
# Need to update /srv/salt/salt/files/master.d/gitfs.conf to remove any
# references to gitfs yamlscsript and add a rootsfs link directly to the 
# development path
#
#mv "${GITFS}" "${GITFS}.${NOW}"
cp ./gitfs.conf "${GITFS}"
sed -i "s|SRC_DIR|${FORMULA_DIR}|" "${GITFS}"

#
# Make sure links in src directory point to actual source
#
rm voluptuous.py yamlscript.py yamlscript_utils.py
ln -sf ../_utils/yamlscript_utils.py .
ln -sf ../_utils/voluptuous.py .
ln -sf ../_renderers/yamlscript.py .

#
# Then need to remove minion cache 
#
rm -rf "${CACHE_DIR}"/gitfs
rm -rf "${CACHE_DIR}"/roots
rm -rf "${CACHE_DIR}"/files
rm -rf "${CACHE_DIR}"/extmods
rm -rf "${CACHE_DIR}"/files
rm -rf "${CACHE_DIR}"/file_lists

#
# Then run highstate to copy over all the new configurations
#
salt '*' state.highstate

#
# Setup softlinks
#
rm -f *.pyc
#touch yamlscript.pyc
#touch yamlscript_utils.pyc
#touch voluptuous.pyc

pushd "${EXTMODS}/renderers"
    rm -f yamscript.py?
    ln -sf "${SRC}/yamlscript.py" .
    ln -sf "${SRC}/yamlscript.pyc" .
popd

pushd "${EXTMODS}/utils"
    rm -f yamscript.py?
    ln -sf "${SRC}/yamlscript_utils.py" .
    ln -sf "${SRC}/yamlscript_utils.pyc" .

    rm -f yamscript.py?
    ln -sf "${SRC}/voluptuous.py" .
    ln -sf "${SRC}/voluptuous.pyc" .
popd