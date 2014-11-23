__author__ = 'root'

#
# This module is only used with WingIDE debugger for testing code within
# The debugging environment
#

import sys
from subprocess import call

from salt.scripts import salt_call

SYNC = True

if __name__ == '__main__':
    argv = sys.argv

    # Soft link the pyc so we can set breakpoints on it
    # NOTE:
    # If source file is changed, salt will regenerate pyc on first call, so we will not
    # be able to use breakpoints till second call.  Better than nothing though fo now
    #
    # This is because if salt detects pyc is stale, it regenerates pyc AND remove soft
    # link in doing so.  I have not figured out a way to force soft links to be non delete-able

    #cmd = "ln -sf /srv/salt-formulas/yamlscript-formula/src/yamlscript.pyc /root/src/salt/salt/renderers/"
    #call(cmd.split())

    # Sync renderers first
    if SYNC:
        #sys.argv = \
        #['/srv/salt-formulas/yamlscript-formula/src/salt-call.py',
        # '--local',
        # 'saltutil.sync_all']
        #salt_call()
        #sys.argv = argv
        call(["salt", "*", "saltutil.sync_all"])

    salt_call()
