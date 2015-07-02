============================================================================
Overview of Features:
============================================================================
- Combine python and YAML in a nice human readable format.  All the
  power of python with readability of YAML;

- Can automatically get pillar data and inject into state;

- Non YAMLScript state files such as YAML, jinja2, and pyobjects can be
  included. Those state files will be injected into the YAMLScript template
  where their values can be read or even modified.  And pre-processing
  on the state files, such a jinja2 template will automatically take
  place in advance.  It can be as easy as just adding pillar data and run
  with no state file modifications except adding the ``!#yamlscript`` shebang
  (or appending it to an existing one);

- Access to read / write to any state file value;

- Requisites are automatically calculated just by using ``$with`` statement
  and nesting (indenting) other states below;

- Test mode available to test state files against a test file before
  deployment;

- Support for pyobjects' maps; YAML format available for creating them;

- Tracking of error positions in python snippets that will display real line
  number error happened on in state file, compared to just a generic stack
  trace related to YAMLScript source files.

**Cavaets**:

    You must escape any scalar value that begins with a ``$`` with another
    ``$`` so to produce ``$4.19``, escape like this: ``$$4.19``.

============================================================================
Pillars:
============================================================================
- Auto pillar mode is disabled by default.  The yamlscript renderer will
  attempt to locate pillar data automatically based on the ``id`` of the
  state file when ``auto mode`` is enabled or individual state id is listed in
  the ``$pillars.enabled`` list.

- The pillar structure must match state structure unless a state-side pillar
  map is set.

- Place ``__pillar__`` within an individual state to override any defaults.

- A pillar alias may be used to shorten paths in pillar data, or
  when combining multiple types of state data within the same pillar data.

.. note::

    Note that any values set in ``pillar`` **WILL** override any defaults
    set within the state file with the exception of values set by python
    code.

**Process**:

    **state defaults  <-- sls defaults  <-- pillar data  <-- generated code**

The following is an example of shortening the pillar path:
--------------------------------------------------------------------------

--------------------------------------------------------------------------
pillar data (``/srv/pillar/users/init.sls``)
--------------------------------------------------------------------------

.. code-block:: yaml

    users:
      mel:
        user:
          user:
            gid: 400
            createhome: True


- OR... shorten the pillar path and use an alias of ``user.user``

.. code-block:: yaml

    users:
      mel:
        user.user:
          gid: 400
          createhome: True

- OR... shorten the pillar path even more with an alias of ``None``

.. code-block:: yaml

    users:
      mel:
        gid: 400
        createhome: True

============================================================================
Pillars state file declaration:
============================================================================

.. code-block:: yaml

    $pillars:
      auto: True|(False)
      disabled:
        - <state_id>
        - <state_id>
      enabled:
        - <state_id>
        - <state_id>: <pillar_id>
      aliases:
        - <state_id>.<state_name>: None|<path>

============================================================================
YAMLScript state file (/srv/salt/users/init.sls)
============================================================================

.. code-block:: yaml

    #!yamlscript

    $pillars:
      auto: True
      aliases:
        - user.user: None
        - ssh.directory: ssh

============================================================================
Pillar data (``/srv/pillar/users/init.sls``):
============================================================================

.. code-block:: yaml

    users:
      mel:
        gid: 400
        createhome: True
        ssh:
          save_keys: False


============================================================================
States:
============================================================================

Every state can contain additional keys / value pairs to provide hints
to the YAMLScript renderer's parser:

**__id__**:

    Override the supplied state id with scalar value.  This is useful
    to prevent duplicate state id's when creating states dynamically:

    .. code-block:: yaml

        $'{0}_group'.format(group.group.name)

**__pillar__**:

    Override `auto`, `disabled` and `enabled` declarations.

    .. code-block:: yaml

        state_id:
          state_name:
            __pillar__: True|False|<string>

    **True:**   Will attempt to merge pillar data
    
    **False**:  Will not attempt to merge pillar data
    
    **string**: string value of the pillar_id to use (map)

**__alias__**:

    An `__alias__` declaration can be set to change the path to
    pillar_data.  Only the path needs to be set since state_id and
    state_path can be obtained.

    .. code-block:: yaml

        state_id:
          state_name:
            __alias__: null
            __alias__: user.user

============================================================================
YAMLScript Commands:
============================================================================

Embed python script into YAML. Indent 4 spaces. Python can be embedded
in multiple locations without fear of using a duplicate key.

All variables and functions created within the embedded python script is
available to all states that follow the code which can be referenced
from the state from within the scalar by starting the scalar with a
dollar ``$`` sign. 

Likewise, the python script can directly set values to individual
states by accessing them via dot notation via
``<state_id>.<state_name>.<key>``.

Pillar data can be manually loaded and accessed by dot-notation so long
as the pillar data is dictionary formed as well by updating the
YAMLScript renderer:

Individual states can also access other state values in the same manner.

**$python**:
    .. code-block:: yaml

        $python |
            # Update the YAMLScript renderer with manually obtained pillar
            # data.  The update command will return a dot.notation accessible
            # dictionary to allow convenient access as well as merge any pillar
            # data with the states within the SLS file based on pillar and
            # alias rules.
            pillar_data = pillar('custom_pillar, {})
            self.update(pillar_data)

            # Directly set the name of the group
            group.group.name = 'apache'

            # Set gid so state can reference and use it
            gid = 3000

        group:
          group.present:
            - __id__: group_apache
            - name:   null
            # Use the value defined in python script for gid
            - gid:    $gid

        state_id:
          state_name.function:
            # Use the group name as Directly set in python as this state id
            - __id__: $'{0}_group'.format(group.group.name)

**$for**:
    Iterate over some object. States may be included within the loop by
    indenting them:

    .. code-block:: yaml

        # Loop through all groups provided in pillar and create dynamic states
        # to create them
        $for name in pillar('absent_groups', []):
          absent_groups:
            group.absent:
              - __id__: $'{0}_absent_group'.format(name)
              - name:   $name

**$with**:
    Allows any state indented below to become an automatic requisites which
    automatically sets the indented state to require the state.

**$if**:

**$elif**:

**$else**:
    Conditionals will only include indented state if conditions are met:

    .. code-block:: yaml

        $if user.user.createhome and user.user.home is not None:
          file.directory:
            - __id__:           $'{0}_user'.format(user.user.name)
            - name:             $user.user.home

**$include**:
    Includes another state file and is not parsed by YAMLScript directly.

    XXX: Provide more detailed explanation

**$extend**:
    Extend an existing state file.  YAMLScript does not parse the file.

    XXX: Provide more detailed explanation

**$import**:
    Includes another state file and is parsed by YAMLScript directly.  All
    states imported are directly able to be referenced.

    XXX: Provide more detailed explanation

**$pillars**:
    Explained above.

**$test_file**:
    A test file can contain expected final `highstate` results that can be
    used to test and verify state files.  See sample test files included
    with the YAMLScript formula for better understanding of usage.

**$defaults**:
    defaults can be set as True or False. If True, all state fields are
    pre-populated with the states default variables and values which may be
    useful when using aliased (short) pillar names to prevent additional
    pillar data from being merged.

**$comment**:
    Just allows a nicely formatted YAML comment block.  Future versions
    of YAMLScript will convert regular style comments starting with the
    pound/number sign ``#`` to `$comment` when loading the YAML and then
    convert back when dumping to allow regular comments to persist.

    Normally comments are lost since they are not parsed and this would not
    be desired in some use cases.

============================================================================
YAMLScript Installation Notes:
============================================================================
- Requires ``salt >= 2014.7.1``
- Documentation is not complete
- Check out the `users-yamlscript-formula` for real world usage

YAMLScript contains a renderer and utils that must be moved to the correct
location in salt base and then synced before use.

Here is an example of how to set things up assuming the `yamlscript-formuala`
is located at ``/srv/salt-formulas/yamlscript-formula`` and the salt base is
located at ``/srv/salt``:

Checkout out http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html to find out how to install formulas.

.. code-block:: yaml

    file_roots:
      base:
        - /srv/salt
        - /srv/salt-formulas/yamlscript-formula

Then YAMLScript modules need to be synced using one of the following:

.. code-block:: bash

    salt-call --local saltutil.sync_all
    salt-call --local state.highstate
    salt '*' saltutil.sync_all
    salt '*' state.highstate

