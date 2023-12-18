#!/usr/bin/env groovy

pipeline {
  agent { label 'conjur-enterprise-common-agent' }

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
    stage('Get InfraPool ExecutorV2 Agent') {
      steps {
        script {
          // Request ExecutorV2 agents for 1 hour(s)
          INFRAPOOL_EXECUTORV2_AGENT_0 = getInfraPoolAgent.connected(type: "ExecutorV2", quantity: 1, duration: 2)[0]
        }
      }
    }

    stage('Validate Changelog'){
      steps{
        parseChangelog(INFRAPOOL_EXECUTORV2_AGENT_0)
      }
    }

    stage('BATS Tests') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './tests-for-this-repo/run-bats-tests'
        }
      }
    }

    stage('Python Linting') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './tests-for-this-repo/run-python-lint'
        }
      }
    }

    stage('Secrets Leak Check') {
      steps {
        script {
          INFRAPOOL_EXECUTORV2_AGENT_0.agentSh './tests-for-this-repo/run-gitleaks'
        }
      }
    }

  }

  post {
    always {
      script {
        INFRAPOOL_EXECUTORV2_AGENT_0.agentStash name: 'xml-report', includes: '*.xml'
        unstash 'xml-report'
        junit '*-junit.xml'
        releaseInfraPoolAgent(".infrapool/release_agents")
      }
    }
  }
}
