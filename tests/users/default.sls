#!yamlscript
#
# This is the default template.
# Note that any values set in pillar WILL over ride any defaults set here with the
# exception of values set by python code
#
# TODO:  Sort out the actual process cause it changed!
# Process: salt defaults  <-- defaults (this file)  <-- pillar  <-- generated code
# Process: salt defaults  <-- defaults (this file)  <-- generated code  <-- pillar
#
# Need to identify this pillar somehow so we user users_auto.
# In future we will just include complete file so we don't need to have this

# Location of pillar file; defaults to same name as state file , so don't
# really need it for this use case.  If provided, it MUST be the first statement
#
# - Keys that do not exist will return Empty type
# - access state values by id_name.state_name.key like user.group.name = 'dev'
#   or user['group']['name']
# - since the data_content is wrapped in a Content wrapper, you can access the
#   dictionary functions like update by appending ._data like
#   user.group._data.update(values) or copy it to a variable first like
#   group = user.group._data; group.update(values)

$comment: |
    Pillars
    -------
    - Default mode will be auto.  Will attempt to locate pillar data
      automatically based on the 'id' of the state file.  Pillar structure
      must match state structure unless a state-side pillar map is set
    - Place __pillar__ within a state to override default
    - A pillar alias may be wanted to shorten paths in pillar data, or
      when combining multiple types of state data within the same pillar.
      An example of shortening the path follows:

      pillar data
      -----------
      users:
        mel:
          user:
            user:
              gid: 400
              createhome: True
      - OR... shorten path and use an alias of 'user.user' -
      users:
        mel:
          user.user:
            gid: 400
            createhome: True
      - OR... shorten path even more with an alias of 'None' -

      You can set the aliases n the state file, to access pillar data as
      follows:

      $pillars state file declaration
      -------------------------------
      $pillars:
          auto: (True)|False
          disabled:
            - <state_id>
            - <state_id>
          enabled:
            - <state_id>
            - <state_id>: <pillar_id>
          aliases:
            - <state_id>.<state_name>: None|<path

      in yamlscript state file:
      -------------------------
      $pillars:
          auto: True
          aliases:
            - user.user: None
            - ssh.directory: ssh

      pillar data:
      ------------
      users:
        mel:
          gid: 400
          createhome: True
          ssh:
            save_keys: False


#

# Will set all the default values from salt; allows short pillar descriptions
$defaults : True

# Looks at the test files in the test directory.  Will help when initially
# setting up pillar to make sure you get desired results before running
# a highstate.  Just run `salt-call --local --out=yaml state.show_sls users`
# and check the logs
#$test_file:
#  - salt://users/tests.mel
#  - salt://users/tests.bobby
#  - salt://users/tests.docker

# Defualt user group to use if you don't add them in pillar
$python: default_users_group = 'users'
#$python: default_users_group = None

$include: users-test.sudo

# See notes above
$pillars:
  auto: False
  disabled: []
  enabled:
    - /etc/sudoers.d
    - sudoer_file
#    - tester: tester_renamed
#  aliases:
#    - tester_renamed.file: None
#    # <state_id>.<state_name>: <path> (None is base (root))

# Main user add loop
$for name, values in pillar('users-test', {}).items():
  $python: |
      if values is None:
          values = {}
      values.update(name=name)

      # self.update(values) will update ALL states with scope with values
      # and will return values wrapped in a ContentWrapper with allows dot
      # notation access.  In order to access dictionary directly within
      # a ContentWrapper, add ._data.  For example:
      values = self.update(values)
      user.user.name = name

      # Set home directory location now
      if user.user.createhome and user.user.home is None:
          user.user.home = '/home/{0}'.format(user.user.name)

      # TODO:  just set user.user.group.name in yaml;
      #          - test with null value and default_users_group
      #
      # If `default_users_group` is `None` and `user.group.name` is `None`
      # (no primary group was set in pillar), one will be created based on the
      # user name
      if default_users_group is None:
        pass # Create one based on something

      # Set gid... considerations:
      #   gid_from_name: False
      #   primary_group: {name: None, gid: None}
      #   gid: None
      if user.user.gid_from_name and user.user.uid is not None:
          user.user.gid = user.user.uid
      elif user.group.gid is not None:
          user.user.gid = user.group.gid
      #elif user.user.gid is None and user.user.uid is not None:
      #    user.user.gid = user.user.uid
      elif user.user.gid is None:
          user.user.gid_from_name = True

      if user.group.name is None and user.user.gid_from_name:
          user.group.name = '{0}'.format(user.user.name)

      # User primary group name
      if user.group.name is not None:
          user.user.groups.append(user.group.name)

      #if sudo.user and sudo.groups:
      #    for g in sudo.groups:
      #        if g not in user.user.groups:
      #            user.user.groups.append(g)

  user:
    group.present:
    - __id__:           $'{0}_user'.format(user.user.name)
    - name:             $default_users_group
    - gid:              null
    user.present:
    - __id__:           $'{0}_user'.format(user.user.name)
    - __alias__:        null
    - name:             null  # Not changable
    - uid:              null
    - gid:              null
    - gid_from_name:    False
    - groups:           []
    - optional_groups:  []
    - remove_groups:    True
    - home:             null
    - createhome:       True
    - password:         null
    - enforce_password: True
    - shell:            null
    - unique:           True
    - system:           False
    - fullname:         null
    - roomnumber:       null
    - workphone:        null
    - homephone:        null
    - date:             null
    - mindays:          null
    - maxdays:          null
    - inactdays:        null
    - warndays:         null
    - expire:           null
    $if user.user.createhome and user.user.home is not None:
      file.directory:
      - __id__:           $'{0}_user'.format(user.user.name)
      - name:             $user.user.home
      - user:             $user.user.name
      - group:            $user.group.name
      - makedirs:         True
      - mode:             770

  $for g in user.user.groups:
    $if g != user.group.name:
      user_groups:
        group.present:
        - __id__:           $'{0}_{1}_group'.format(user.user.name, g)
        - name:             $g

  # TODO:
  # Make sure I can access variables that were set in previous python
  # sessions both as a replacement value AND in other python code that may
  # get called!
  #
  # TODO:
  # Make this more defensive!  not guarenteed ssh values exist in pillar
  # Maybe just keep backup vlaues in ContentWrapper of values that dont delete
  # so if a value does not exist; then check backup before raising KeyError!
  #if user.user.createhome and user.user.home:
  $if user.user.createhome and user.user.home and values.ssh.save_keys:
    $with File('{0}_user'.format(user.user.name), 'require'):
      $with ssh_directory:
        file:
        - __id__:           $'{0}/.ssh'.format(user.user.home)
        - __alias__:        ssh
        - user:             $user.user.name
        - group:            $user.group.name
        - makedirs:         true
        - mode:             700
        - directory

        # Going to want ssh_directory above to have a with: on line above it; then when we parse
        # the with, we know next statement is what it will belong to; so parse the next statement
        # then execure it with 'with' in front of it?

        # XXX:  Name is coming up wrong; FIX that, but then set the ID as directory
        # not using ssh_private_key!   ... same for above etc!!!!
        ssh_private_key:
          file:
          - __id__:           $'{0}/.ssh/id_{1}'.format(user.user.home, values.ssh.key_type)
          - name:             $'{0}/.ssh/id_{1}'.format(user.user.home, values.ssh.key_type)
          - user:             $user.user.name
          - group:            $user.group.name
          - contents_pillar:  $'users:{0}:ssh:keys:private'.format(user.user.name)
          - makedirs:         true
          - mode:             600
          - managed

        # TODO TEST and remove name; will it get value from __ID__?  It should
        ssh_public_key:
          file:
          - __id__:           $'{0}/.ssh/id_{1}.pub'.format(user.user.home, values.ssh.key_type)
          #- name:             $'{0}/.ssh/id_{1}.pub'.format(user.user.home, values.ssh.key_type)
          - user:             $user.user.name
          - group:            $user.group.name
          - contents_pillar:  $'users:{0}:ssh:keys:public'.format(user.user.name)
          - makedirs:         true
          - mode:             644
          - managed

        $if auth_present.ssh_auth.name or auth_present.ssh_auth.names:
          auth_present:
            ssh_auth.present:
              - __id__:         $'{0}_user_auth_present'.format(user.user.name)
              - user:           $user.user.name
              #- present

        # This formula is wrong... user.user.name??  more like auth_absent.ssh_auth.name
        $if auth_absent.ssh_auth.name or auth_absent.ssh_auth.names:
          auth_absent:
            ssh_auth:
              - __id__:         $'{0}_user_auth_absent'.format(user.user.name)
              - user:           $user.user.name
              - absent
