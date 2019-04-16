# bash-lib
```
                   _______________  _______________
                 .'               .'               .|
               .'               .'               .' |
             .'_______________.'______________ .'   |
             | ___ _____ ___ || ___ _____ ___ |     |
             ||_=_|__=__|_=_||||_=_|__=__|_=_||     |
       ______||_____===_____||||_____===_____||     | __________
    .'       ||_____===_____||||_____===_____||    .'          .'|
  .'         ||_____===_____||||_____===_____||  .'          .'  |
.'___________|_______________||_______________|.'__________.'    |
|.----------.|.-----___-----.||.-----___-----.||    |_____.----------.
|]          |||_____________||||_____________|||  .'      [          |
||          ||.-----___-----.||.-----___-----.||.'        |          |
||          |||_____________||||_____________|||==========|          |
||          ||.-----___-----.||.-----___-----.||    |_____|          |
|]         o|||_____________||||_____________|||  .'      [        'o|
||          ||.-----___-----.||.-----___-----.||.'        |          |
||          |||             ||||_____________|||==========|          |
||          |||             |||.-----___-----.||    |_____|          |
|]          |||             ||||             |||  .'      [          |
||__________|||_____________||||_____________|||.'________|__________|
''----------'''------------------------------'''----------''
            (o)LGB                           (o)
```

The place to store functions that are used in pipelines for multiple repos.

Please add whatever is useful to you, but keep it tidy so its still useful to everyone else :)

## Usage
Firstly acquire a clone of bash-lib:
1. If submodules are acceptable in your workflow, I recommend adding a submodule `git submodule add git@github.com:conjurinc/bash-lib bash-lib`
1. Otherise you can use emulate submodules with a bash function eg:<sup>[1](#footnote-1)</sup>
```bash
function init_bash_lib(){
  # shellcheck disable=SC2086,SC2046
  d="$(cd $(dirname ${BASH_SOURCE[0]}); pwd)"
  ref_path="${d}/.bash_lib_ref"
  pushd ${d}
    git clone --recurse-submodules git@github.com:conjurinc/bash-lib
    pushd bash-lib
      if [[ -e "${ref_path}" ]]
      then
        git checkout "$(cat ${ref_path})"
      else
        git rev-parse HEAD > "${ref_path}"
        echo "Please commit ${ref_path} to ensure a consistent version is used"
      fi
      . init.sh
    popd
  popd
}
```

It is highly important that however you acquire bash-lib, you always **use it at
a pinned verison**. Hopefully bash-lib will end up widely used, and we do not
want to break every project when updating bash-lib. Each project must update the pin
at a time that suits them to avoid unexpected breakages.

Once you have bash-lib cloned in your project, you source two things:

1. Source `bash-lib/init.sh`. This ensures submodules are initalised and sets the BASH_LIB env var to the absolute path to the bash-lib dir. This makes it easy to source libraries from other scripts.
1. Source `${BASH_LIB}/lib-name/lib.sh` for any libraries you are interested in.

You are now ready to use bash-lib functions :)

## Structure
The `/init.sh` script sets up everything required to use the library, most
importantly the `BASH_LIB` variable which gives the absolute path to the root
of the library and should be used for sourcing the modules.

The repo is organised into libraries, each library is a directory that has a
lib.sh file. Sourcing the lib.sh for a library should expose all the functions
that library offers. The lib.sh file may source or reference other supporting
files within it's directory.

```
/init.sh
/lib-name/
    lib.sh # main library file
    supporting-file.yaml # a supporting file
/tests-for-this-repo # self tests for this repo.
```
## Style Guide
Follow the [google shell style guide](https://google.github.io/styleguide/shell.xml#Naming_Conventions).
TL;DR:
1. Use snake_case function and variable names
1. Use `function` when declaring functions.


## Contents

<!-- html table due to markdown's lack of support for lists within tables -->
<table>
  <thead>
    <tr>
      <th>Library</th>
      <th>Description</th>
      <th>Functions</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="filehandling/lib.sh">filehandling</a></td>
      <td>Functions relating to file and path handling
      <td>
        <ol>
          <li> abs_path: Ensure a path is absolute</li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="git/lib.sh">git</a></td>
      <td>Git helpers</td>
      <td>
        <ol>
          <li>repo_root: find the root of the current git repo</li>
          <li>all_files_in_repo: list files tracked by git</li>
        </ol>
      </td>
    </tr>
      <td><a href="helpers/lib.sh">helpers</a></td>
      <td>Bash scripting helpers</td>
      <td>
        <ol>
          <li>die: print message and exit 1</li>
          <li>spushd/spopd: safe verisons of pushd & popd that call die if the push/pop fails, they also drop stdout. </li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="k8s/lib.sh">k8s</a></td>
      <td>Utils for connecting to K8s</td>
      <td>
        <ol>
          <li>build_gke_image: Build docker image for running kubectl commands against GKE</li>
          <li>delete_gke_image: Delete image from GKE</li>
          <li>run_docker_gke_command: Run command in gke-utils container, already authenticated to k8s cluster.</li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="logging/lib.sh">logging</a></td>
      <td>Helpers related to login</td>
      <td>
        <ol>
          <li>announce: echo message in ascii banner to distinguish it from other log messages.</li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="test-utils/lib.sh">test-utils</a></td>
      <td>Helpers for executing tests</td>
      <td>
        <ol>
          <li>shellcheck_script: execute shellcheck against a script, uses docker.</li>
          <li>find_scripts: find git tracked files with .sh extension</li>
          <li>tap2junit: Convert a subset of <a href="http://testanything.org/">TAP</a> to JUnit XML. Retains logs for errors</li>
        </ol>
      </td>
    </tr>
  </tbody>
</table>

## Testing
Tests are written using [BATS](https://github.com/bats-core/bats). Each lib should have a `lib-name.bats` file in [tests-for-this-repo](/tests-for-this-repo).
Asserts are provided by [bats-assert-1](https://github.com/jasonkarns/bats-assert-1). The value in these is that they provide useful debugging output when the assertion fails, eg expected x got y.

Example:
```bash
# source support and assert libraries
. "${BASH_LIB}/test-utils/bats-support/load.bash"
. "${BASH_LIB}/test-utils/bats-assert-1/load.bash"

# source the library under test
. "${BASH_LIB}/git/lib.sh"

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

Test fixtures should go in /tests-for-this-repo/fixtures/lib-name.


### Footnotes
<a name="footnote-1">1</a>: Early Readers/Reviewers may notice that the
submodule alternative clone function fails. This is because most of the
content hasn't been merged to master yet (its still in the initial_libs branch)