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

ln -sf /srv/salt-formulas/yamlscript-formula/src/yamlscript.py /var/cache/salt/minion/extmods/renderers/
ln -sf /srv/salt-formulas/yamlscript-formula/src/yamlscript_utils.py /var/cache/salt/minion/extmods/utils/
ln -sf /srv/salt-formulas/yamlscript-formula/src/voluptuous.py /var/cache/salt/minion/extmods/utils/

mkdir -p /srv/salt/_renderers/
mkdir -p /srv/salt/_utils/
ln -sf /srv/salt-formulas/yamlscript-formula/src/yamlscript.py /srv/salt/_renderers/
ln -sf /srv/salt-formulas/yamlscript-formula/src/voluptuous.py /srv/salt/_utils/
ln -sf /srv/salt-formulas/yamlscript-formula/src/yamlscript_utils.py /srv/salt/_utils/

ln -s /srv/salt-formulas/yamlscript-formula/tests/users /srv/salt/users-test
ln -sf /srv/salt-formulas/yamlscript-formula/tests/users/pillar /srv/pillar/users-test
