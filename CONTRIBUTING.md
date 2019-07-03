# Contributing
Thanks for your interest in bash-lib. Before contributing, please take a
moment to read and sign our [Contributor
Agreement](CyberArk_Open_Source_Contributor_Agreement.pdf). This provides
patent protection for all bash-lib users and allows CyberArk to
enforce its license terms. Please email a signed copy to <a
href="oss@cyberark.com">oss@cyberark.com</a>

Contributed bash functions are most welcome! The more we share the less we
duplicate each other. In order to keep this repo tidy, every function must be
documented in the readme and tested, the lint scripts enforce these rules.

1. Add the libraries or functions that you need
2. Add BATS tests for all new top level functions
3. Add descriptions for each function to the contents table in this readme
4. Run ./run-tests to ensure all tests pass before submitting
5. Create a PR
6. Wait for review

## Style Guide
Follow the [google shell style guide](https://google.github.io/styleguide/shell.xml#Naming_Conventions).
TL;DR:
1. Use snake_case function and variable names
1. Use `function` when declaring functions.
1. Don't use .sh extensions

## Testing
Tests are written using [BATS](https://github.com/bats-core/bats). Each lib has a `lib-name.bats` file in [tests-for-this-repo](/tests-for-this-repo).
Asserts are provided by [bats-assert-1](https://github.com/jasonkarns/bats-assert-1). Asserts provide useful debugging output when the assertion fails, eg expected x got y.

Example:
```bash
# source support and assert libraries
. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

# source the library under test
. "${BASH_LIB_DIR}/git/lib"

# define a test that calls a library function
@test "it does the thing" {
  some_prep_work
  # run is a wrapper that catches failures so that assertsions can be run,
  # otherwise the test would immediately fail.
  run does_the_thing
  assert_success
  assert_output "thing done"
}
```

Test fixtures should go in /tests-for-this-repo/[fixtures](tests-for-this-repo/fixtures)/lib-name.
