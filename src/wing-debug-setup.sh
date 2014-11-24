#!/bin/bash

# To set up breakpoints in WingIDE, we need to softlink some stuff

# Need to use salt git develop branch
# In Wing...
# Project -> Add Existing Directory ... /srv/salt-formulas
# Project -> Project Properties -> Debug/Execute -> Main Entry Point -> /srv/salt-formulas/yamlscript-formula/src/salt-call

# To display yaml output without running a highstate (state.show.sls)
# Debug -> Debug Environment -> Environment --> --local --out=yaml state.show_sls users-test

# Or just run a highstate
# Debug -> Debug Environment -> Environment --> --local state.highstate -l debug
#

# IMPORTANT NOTE.  Be sure we are using the rootfs version, not gitfs or paths will be incorrect!
# Set breakpoint on /var/cache/salt/minion/extmods/...

ln -sf /var/cache/salt/minion/extmods/renderers/yamlscript.pyc .
ln -sf /var/cache/salt/minion/extmods/utils/yamlscript_utils.pyc .
ln -sf /var/cache/salt/minion/extmods/utils/voluptuous.pyc .
