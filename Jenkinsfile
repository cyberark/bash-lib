#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  environment {
    BATS_OUTPUT_FORMAT="junit"
  }

  stages {
    stage('Bash Linting') {
      environment {
        BATS_SUITE="BATS-Lint"
      }
      steps {
        sh './tests-for-this-repo/run-bats-tests.sh tests-for-this-repo/lint.bats'
      }
    }

    stage('Python Linting') {
      steps {
        sh './tests-for-this-repo/python-lint.sh'
      }
    }

    stage('Bash Tests') {
      environment {
        BATS_SUITE="BATS-Tests"
      }
      steps {
        sh './tests-for-this-repo/run-bats-tests.sh $(ls tests-for-this-repo/*.bats|grep -v lint.bats)'
      }
    }
  }

  post {
    always {
      junit '*-junit.xml'
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
