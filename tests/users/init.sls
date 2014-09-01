#!yamlscript
#
# This is the test template.
#
# See default.sls for inline documentation
$defaults: True
$test_file:
  - salt://users-test/tests.mel
  - salt://users-test/tests.bobby
  - salt://users-test/tests.docker
  - salt://users-test/tests.tester

$import: users-test.default

# Tests to test token replacement recursion
$python: |
    test_value = True

    city = 'Kitchener'
    building = ['Campus 1', '$city']
    a = "A"
    b = "B"
    c = "C"
    d = "D"
    e = "E"
    f = {'f': 'is for fun', 'l': '$lister'}
    g = "G"
    lister = [1, 2, 3, 4, 5, '$a']

    # Test importing salt utils while using a pillar for value
    import salt.utils.ipaddr
    netmask = str(salt.utils.ipaddr.IPNetwork(pillar('my_ip_range')).netmask)

$if test_value:
#$if False:
  tester:
    file:
    - __pillar__:       tester_renamed
    - __alias__:        None
    - name:             $mel_shadow_group.group.name
    - user:             $test_value
    - group:            sudo
    #- test1:            $mel_shadow_group.group.name
    - not_real_key1:    {'wing': 'left', 'floor': 2, 'building': '$building'}
    - not_real_key2:    [$a, [$b, {'c': [$c, $d, $e, [$f, $g]]}]]
    - not_real_key3:    $f
    - netmask:          $netmask
    - if:               True
    - custom:           $mel_user.user.name
    - password:         null
    - contents_pillar:  null
    - makedirs:         true
    - mode:             644
    - require:
      - file: mel_user
    - managed
$elif not test_value:
  tester:
    file:
    - if:               elif not test_value
    - managed
$elif False and test_value:
  tester:
    file:
    - if:               elif test_value
    - managed
$else:
  tester:
    file:
    - if:               else
    - managed
$python: |
    test_value = False

user2:
    user.present:
    - home: $pillar('HOME_PATH')
