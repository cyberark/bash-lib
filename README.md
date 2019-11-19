# bash-lib

Introductory blog post: https://www.conjur.org/blog/stop-bashing-bash/

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

## Release Status: Alpha
TL;DR: Ready for use, but needs expansion.

The functions in this repo are tested and ready for use, but certain libs
are pretty much place holders (eg logging). Those need further contributions
before they provide a comprehensive solution.

## License: Apache 2.0
See the [license file](LICENSE)

## Usage

Add bash-lib into your project in the way that best fits your workflow. The only requirement is that you **pin the version of
bash-lib that you use**. This is important so that changes to bash-lib do not have the power to break all projects that use
bash-lib. Your project can then test updates to bash-lib and roll forward periodically.

Options:
* Add a submodule: they are an easy way to integrate bash-lib and automatically use a single SHA until manually updated. Submodules add a pointer from a mount point in your repo to the external repo (bash-lib), and require workflow changes to ensure that pointer is derferenced during clone, checkout and some other opertaions.
* Add a subtree: This repo uses subtrees to pull in test dependencies. Subtrees copy an external repo into a subdirectory of the host repo, no workflow changes are required. Subtrees naturally keep a single version of bash-lib until explicitly updated. Note that subtree merge commits do not rebase well :warning:, so best to keep subtree updates in separate PRs from normal commits.
* Clone bash-lib in your deployment process, bash-lib doesn't have to be within your repo, just needs to be somewhere where your scripts can source [init](init). This is where it's most important that you implement a mechanism to always use the same SHA, as a **clone will track master by default, which is not an allowed use of bash-lib**.

Once you have bash-lib cloned in your project, you source two things:

1. Source `bash-lib/init`. This ensures submodules are initalised and sets the BASH_LIB_DIR env var to the absolute path to the bash-lib dir. This makes it easy to source libraries from other scripts.
2. Source `${BASH_LIB_DIR}/lib-name/lib` for any libraries you are interested in.

You are now ready to use bash-lib functions :)

## Structure
The `/init` script sets up everything required to use the library, most
importantly the `BASH_LIB_DIR` variable which gives the absolute path to the root
of the library and should be used for sourcing the modules.

The repo is organized into libraries, each library is a directory that has a
lib file. Sourcing the lib for a library should expose all the functions
that library offers. The lib file may source or reference other supporting
files within it's directory.

```
.
├── libname
│   ├── lib
│   └── supporting-file
├── init # init script, source this first
├── run-tests # top level test script, executes all tests
├── secrets.yml # secrets required for executing tests
├── test-utils
│   ├── bats # git subtree
│   ├── bats-assert-1 # git subtree
│   ├── bats-support # git subtree
│   ├── lib
│   └── tap2junit
└── tests-for-this-repo
    ├── filehandling.bats
    ├── fixtures #
    │   └── libname # Dir containing test fixtures for a library
    ├── tap2junit
    ├── libname.bats # contains tests for libname/lib
    ├── python-lint # supporting files for python lint
    ├── run-bats-tests # script to run bats tests
    ├── run-gitleaks # script to check for leaked secrets
    └── run-python-lint # script to run python lint
```

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
      <td><a href="filehandling/lib">filehandling</a></td>
      <td>Functions relating to file and path handling
      <td>
        <ol>
          <li> <b>abs_path</b>: Ensure a path is absolute</li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="git/lib">git</a></td>
      <td>Git helpers</td>
      <td>
        <ol>
          <li><b>repo_root</b>: Find the root of the current git repo.</li>
          <li><b>all_files_in_repo</b>: List files tracked by git.</li>
          <li><b>remote_latest_tag</b>: Returns the symbolic name of the latest tag from a remote.</li>
          <li><b>remote_latest_tagged_commit</b>: Returns the SHA of the most recently tagged commit in a remote repo (<code>tag^{}</code>).</li>
          <li><b>remote_sha_for_ref</b>: Returns the SHA for a given ref from a named remote.</li>
          <li><b>remote_tag_for_sha</b>: Returns the tag corresponding to a SHA from a named remote - if there is one.</li>
          <li><b>tracked_files_excluding_subtrees</b>: List files tracked by git, but excluding any files that are in paths listed in <code>.gittrees</code>.</li>
          <li><b>cat_gittrees</b>: Returns the contents of .gittrees from the top level of the repo, excluding any comments. Fails if .gittrees is not present.</li>
        </ol>
      </td>
    </tr>
      <td><a href="helpers/lib">helpers</a></td>
      <td>Bash scripting helpers</td>
      <td>
        <ol>
          <li><b>die</b>: print message and exit 1</li>
          <li><b>spushd/spopd</b>: Safe verisons of pushd & popd that call die if the push/pop fails, they also drop stdout. </li>
          <li><b>retry</b>: Retry a command until it succeeds up to a user specified maximum number of attempts. Escalating delay between attempts.</li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="k8s/lib">k8s</a></td>
      <td>Utils for connecting to K8s</td>
      <td>
        <ol>
          <li><b>build_gke_image</b>: Build docker image for running kubectl commands against GKE.</li>
          <li><b>delete_gke_image</b>: Delete image from GKE.</li>
          <li><b>run_docker_gke_command</b>: Run command in gke-utils container, already authenticated to k8s cluster.</li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="logging/lib">logging</a></td>
      <td>Helpers related to login</td>
      <td>
        <ol>
          <li><b>announce</b>: Echo message in ascii banner to distinguish it from other log messages.</li>
        </ol>
      </td>
    </tr>
    <tr>
      <td><a href="test-utils/lib">test-utils</a></td>
      <td>Helpers for executing tests</td>
      <td>
        <ol>
          <li><b>shellcheck_script</b>: Execute shellcheck against a script, uses docker.</li>
          <li><b>find_scripts</b>: Find git tracked files with extension.</li>
          <li><b>tap2junit</b>: Convert a subset of <a href="http://testanything.org/">TAP</a> to JUnit XML. Retains logs for errors.</li>
        </ol>
      </td>
    </tr>
  </tbody>
</table>

# Contributing
For further information on contributing, style & testing, please see [CONTRIBUTING.md](CONTRIBUTING.md)

# Maintainers
* [Hugh Saunders](https://github.com/hughsaunders)
