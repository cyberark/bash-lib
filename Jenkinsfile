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

    stage('BATS Tests') {
      steps {
        sh './tests-for-this-repo/run-bats-tests'
      }
    }

    stage('Python Linting') {
      steps {
        sh './tests-for-this-repo/run-python-lint'
      }
    }

    stage('Secrets Leak Check') {
      steps {
        sh './tests-for-this-repo/run-gitleaks'
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
