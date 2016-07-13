================================================================================
  ``am add-fpr-rule`` Example Usage
================================================================================

This document provides an example of how one might use the ``add-fpr-rule`` tool
in Archivematica's devtools to create a new FPR tool, command and rule. In this
example, we are creating a tool, a command, and a rule that allow the use of
MediaConch for the validation of Matroska (.mkv) video files.

Note the following. In the code examples below, the output SQL is formatted for
ease of reading. The actual output of ``add-fpr-rule`` does not contain this
formatting. Also, empty input by the user during the CLI is represented by a
blank line.


Create the Tool
================================================================================

First, create the MediaConch tool::

    $ sudo am add-fpr-rule fptool
    description:
    MediaConch
    version:
    16.05
    INSERT INTO `fpr_fptool` (
        `uuid`,
        `description`,
        `version`,
        `enabled`,
        `slug`
    ) VALUES (
        '7f0bd906-ef16-4b74-b01d-2a35e10df0dc',
        'MediaConch',
        '16.05',
        1,
        'mediaconch-1605'
    );


Create the Command
================================================================================

Assuming the file ``mediaconch.py`` contains the desired command code and is in
the current directory::

    $ sudo am add-fpr-rule fpcommand mediaconch.py
    description:
    Validate using MediaConch
    tool_id:
    7f0bd906-ef16-4b74-b01d-2a35e10df0dc
    command_usage:
    validation
    script_type:
    pythonScript
    output_location:

    output_format_id:

    verification_command_id:

    event_detail_command_id:

    replaces_id:

    INSERT INTO `fpr_fpcommand` (
        `replaces_id`,
        `enabled`,
        `lastmodified`,
        `uuid`,
        `tool_id`,
        `description`,
        `command`,
        `script_type`,
        `output_location`,
        `output_format_id`,
        `command_usage`,
        `verification_command_id`,
        `event_detail_command_id`
    ) VALUES (
        NULL,
        1,
        '2016-07-13 17:40:24',
        '172b7d5e-abfd-4f99-8345-922dcb53f1af',
        '7f0bd906-ef16-4b74-b01d-2a35e10df0dc',
        'Validate using MediaConch',
        'import json\nimport subprocess\nimport sys\nimport uuid\n\nfrom lxml import etree\n\nNS = \'{https://mediaarea.net/mediaconch}\'\n\n\nclass MediaConchException(Exception):\n    pass\n\n\ndef parse_mediaconch_data(target):\n    \"\"\"Run `mediaconch -mc -iv 4 -fx <target>` against `target` and return an\n    lxml etree parse of the output.\n\n    .. note::\n\n        At present, MediaConch (v. 16.05) will give terse output so long as you\n        provide *some* argument to the -iv option. With no -iv option, you will\n        get high verbosity. To be specific, low verbosity means that only\n        checks whose tests fail in the named \"MediaConch EBML Implementation\n        Checker\" will be displayed. If none fail, the EBML element will contain\n        no <check> elements.\n\n    \"\"\"\n\n    args = [\'mediaconch\', \'-mc\', \'-iv\', \'4\', \'-fx\', target]\n    try:\n        output = subprocess.check_output(args)\n    except subprocess.CalledProcessError:\n        raise MediaConchException(\"MediaConch failed when running: %s\" % (\n            \' \'.join(args),))\n    try:\n        return etree.fromstring(output)\n    except etree.XMLSyntaxError:\n        raise MediaConchException(\n            \"MediaConch failed when attempting to parse the XML output by\"\n            \" MediaConch\")\n\n\ndef get_impl_check_name(impl_check_el):\n    name_el = impl_check_el.find(\'%sname\' % NS)\n    if name_el is not None:\n        return name_el.text\n    else:\n        return \'Unnamed Implementation Check %s\' % uuid.uuid4()\n\n\ndef get_check_name(check_el):\n    return check_el.attrib.get(\n        \'name\', check_el.attrib.get(\'icid\', \'Unnamed Check %s\' % uuid.uuid4()))\n\n\ndef get_check_tests_outcomes(check_el):\n    \"\"\"Return a list of outcome strings for the <check> element `check_el`.\"\"\"\n    outcomes = []\n    for test_el in check_el.iterfind(\'%stest\' % NS):\n        outcome = test_el.attrib.get(\'outcome\')\n        if outcome:\n            outcomes.append(outcome)\n    return outcomes\n\n\ndef get_impl_check_result(impl_check_el):\n    \"\"\"Return a dict mapping check names to lists of test outcome strings.\"\"\"\n    checks = {}\n    for check_el in impl_check_el.iterfind(\'%scheck\' % NS):\n        check_name = get_check_name(check_el)\n        test_outcomes = get_check_tests_outcomes(check_el)\n        if test_outcomes:\n            checks[check_name] = test_outcomes\n    return checks\n\n\ndef get_impl_checks(doc):\n    \"\"\"When not provided with a policy file, MediaConch produces a series of\n    XML <implementationChecks> elements that contain <check> sub-elements. This\n    function returns a dict mapping implementation check names to dicts that\n    map individual check names to lists of test outcomes, i.e., \'pass\' or\n    \'fail\'.\n\n    \"\"\"\n\n    impl_checks = {}\n    path = \'.%smedia/%simplementationChecks\' % (NS, NS)\n    for impl_check_el in doc.iterfind(path):\n        impl_check_name = get_impl_check_name(impl_check_el)\n        impl_check_result = get_impl_check_result(impl_check_el)\n        if impl_check_result:\n            impl_checks[impl_check_name] = impl_check_result\n    return impl_checks\n\n\ndef get_event_outcome_information_detail(impl_checks):\n    \"\"\"Return a 2-tuple of info and detail.\n\n    - info: \'pass\' or \'fail\'\n    - detail: human-readable string indicating which implementation checks\n      passed or failed. If implementation check as a whole passed, just return\n      the passed check names; if it failed, just return the failed ones.\n\n    \"\"\"\n\n    info = \'pass\'\n    failed_impl_checks = []\n    passed_impl_checks = []\n    for impl_check, checks in impl_checks.iteritems():\n        passed_checks = []\n        failed_checks = []\n        for check, outcomes in checks.iteritems():\n            for outcome in outcomes:\n                if outcome == \'pass\':\n                    passed_checks.append(check)\n                else:\n                    info = \'fail\'\n                    failed_checks.append(check)\n        if failed_checks:\n            failed_impl_checks.append(\n                \'The implementation check %s returned\'\n                \' failure for the following check(s): %s.\' % (\n                    impl_check, \', \'.join(failed_checks)))\n        else:\n            passed_impl_checks.append(\n                \'The implementation check %s returned\'\n                \' success for the following check(s): %s.\' % (\n                    impl_check, \', \'.join(passed_checks)))\n    if info == \'pass\':\n        if passed_impl_checks:\n            return info, \' \'.join(passed_impl_checks)\n        return info, \'All checks passed.\'\n    else:\n        return info, \' \'.join(failed_impl_checks)\n\n\ndef main(target):\n    \"\"\"Return 0 if MediaConch can successfully assess whether the file at\n    `target` is a valid Matroska (.mkv) file. Parse the XML output by\n    MediaConch and print a JSON representation of that output.\n\n    \"\"\"\n\n    try:\n        doc = parse_mediaconch_data(target)\n        impl_checks = get_impl_checks(doc)\n        info, detail = get_event_outcome_information_detail(impl_checks)\n        print json.dumps({\n            \'eventOutcomeInformation\': info,\n            \'eventOutcomeDetailNote\': detail\n        })\n        return 0\n    except MediaConchException as e:\n        return e\n\n\nif __name__ == \'__main__\':\n    target = sys.argv[1]\n    sys.exit(main(target))\n',
        'pythonScript',
        NULL,
        NULL,
        'validation',
        NULL,
        NULL
    );


Create the Rule
================================================================================

In order to create rules, you need to know the UUID(s) of the file formats that
you want your rule to apply commands to. For example, to get the "Generic MKV"
UUID::

    mysql> SELECT uuid FROM fpr_formatversion WHERE description = 'Generic MKV';
    4dc90ad8-319a-46be-95c8-390b189867d9


Now create the rule::

    $ sudo am add-fpr-rule fprule
    purpose:
    validation
    command_id:
    172b7d5e-abfd-4f99-8345-922dcb53f1af
    format_id:
    4dc90ad8-319a-46be-95c8-390b189867d9

    INSERT INTO `fpr_fprule` (
        `replaces_id`,
        `enabled`,
        `lastmodified`,
        `uuid`,
        `purpose`,
        `command_id`,
        `format_id`,
        `count_attempts`,
        `count_okay`,
        `count_not_okay`
    ) VALUES (
        NULL,
        1,
        '2016-07-13 17:50:27',
        '271300ff-72d6-4db0-85a4-4bbce0fab704',
        'validation',
        '172b7d5e-abfd-4f99-8345-922dcb53f1af',
        '4dc90ad8-319a-46be-95c8-390b189867d9',
        0,
        0,
        0
    );


