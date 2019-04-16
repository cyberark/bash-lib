#!/usr/bin/python

import os
import re
import sys
from junit_xml import TestSuite, TestCase


class Tap2JUnit:
    """ This class reads a subset of TAP (Test Anything protocol)
    and writes JUnit XML.

    Two line formats are read:
    1. (not )?ok testnum testname
    2. # diagnostic output

    1. Starts a new test result.
    2. Adds diagnostic information to the last read result

    Any 2. lines found before a 1. line are ignored.
    Any lines not matching either pattern are ignored.

    This script was written because none of the tap2junit converters
    I could find inserted the failure output into the junit correctly.
    And IMO a failed test with no indication of why is useless.
    """

    def __init__(self, test_suite, test_class):
        self.test_suite = test_suite
        self.test_class = test_class
        # This Regex matches a (not) ok testnum testname line from the
        # TAP specification, using named capture groups
        self.result_re = re.compile(
            r"^(?P<result>not )?ok\s*(?P<testnum>[0-9])+\s*(?P<testname>.*)$")
        self.comment_re = re.compile(r"^\s*#")
        self.case = None
        self.cases = []

    def process_line(self, line):
        """ This funuction reads a tap stream line by line
            and groups the diagnostic output with the relevant
            result in a dictionary.

            Outputs a list of dicts, one for each result
        """
        match = self.result_re.match(line)
        if match:
            # This line starts a new test result
            self.case = match.groupdict()
            self.case['stderr'] = []
            self.cases.append(self.case)

            return

        match = self.comment_re.match(line)
        if match and self.case:
            # This line contains diagnostic
            # output from a failed test
            self.case['stderr'].append(re.sub(r'^\s*#', '', line).rstrip())

    def convert(self, infile=sys.stdin, out=sys.stdout):
        """ Reads a subset of TAP and writes JUnit XML """
        # read lines
        for line in infile.readlines():
            self.process_line(line)

        # Convert line dicts to test case objects
        case_objs = []
        for case in self.cases:
            case_obj = TestCase(case['testname'], self.test_class, 0, '', '')
            if case['result'] == 'not ':
                case_obj.add_failure_info(output="\n".join(case['stderr']))
            case_objs.append(case_obj)

        # Combine test cases into a suite
        suite = TestSuite(self.test_suite, case_objs)

        # Write the suite out as XML
        TestSuite.to_file(out, [suite])


def main():
    t2j = Tap2JUnit(
        os.environ.get('JUNIT_TEST_SUITE', 'tap2junit'),
        os.environ.get('JUNIT_TEST_CLASS', 'tap2junit')
    )
    t2j.convert()


if __name__ == "__main__":
    main()
