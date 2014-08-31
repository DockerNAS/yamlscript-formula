Overview of Features:
---------------------
- Combine python and yaml in a nice human readable yaml format.  All the
  power of python with readability of YAML
- Can automatically get pillar data and inject into state
- Non yaml state files such as yaml, jinga, and pyobjects can be included.
  Those state files will be injected into the yamlscript template
  where their values can be read or even modified.  And pre-processing
  on the state files, such a jinga2 templating will automatically take
  place in advance.  It can be as easy as just adding pillar data and run
  with no state file modifications except adding the !#yamlscript shebang (or
  appending it to an existing one)
- Access to read / write to any state file value
- requisites are automatically calculated just by using with: statement
  and nesting (indenting) underneath
- test mode available to test state files against a test file before deployment
- support for pyobjects maps; yaml format available for creating them
- tracking of error positions in python snippets that will display real line number
  error is one in state file compare to a generic stack trace related to
  yamlscript source files

Cavaets:
--------
- You must escape any scalar value that begins with a '$' with another
  '$' so to produce '$4.19', escape like this: '$$4.19'

Notes:
------
- salt git develop version is required to run Yamlscript or any version
  > salt 2014.1.0-6384-g45ed9ce
- Documentation is not complete
- Check out the users-yamlscript-formula for real world usage

YAMLSCRIPT INSTALLATION NOTES:
------------------------------
Yamlscript contains a renderer and utils that must be moved to the correct
location in salt base and then synced before use.

Here is an example of how to set things up assuming the yamlscript-formuala
is located at `/srv/salt-formulas/yamlscript-formula` and the salt base is
located at `/srv/salt`:

```
mkdir -p /srv/salt/_renderers/
mkdir -p /srv/salt/_utils/
cp /srv/salt-formulas/yamlscript-formula/src/yamlscript.py /srv/salt/_renderers/
cp /srv/salt-formulas/yamlscript-formula/src/voluptuous.py /srv/salt/_utils/
cp /srv/salt-formulas/yamlscript-formula/src/yamlscript_utils.py /srv/salt/_utils/
```

Now yamscript modules need to be synced using one of the following:

```
salt-call --local saltutil.sync_all
salt-call --local state.highstate
salt '*' saltutil.sync_all
salt '*' state.highstate
```

