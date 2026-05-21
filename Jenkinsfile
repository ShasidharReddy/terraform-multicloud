pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 2, unit: 'HOURS')
  }

  parameters {
    choice(name: 'ENVIRONMENT',     choices: ['dev', 'qa', 'stage', 'prod', 'all'],           description: 'Target environment(s)')
    choice(name: 'CLOUD',           choices: ['aws', 'azure', 'gcp', 'all'],                   description: 'Target cloud provider(s)')
    choice(name: 'ACTION',          choices: ['plan', 'apply', 'destroy'],                      description: 'Terraform action')
    choice(name: 'COMPUTE_TYPE',    choices: ['vm', 'kubernetes'],                              description: 'Compute type: VM or Kubernetes')
    choice(name: 'DB_ENGINE',       choices: ['postgresql', 'mysql', 'sqlserver', 'aurora-postgresql', 'aurora-mysql'], description: 'Database engine')
    booleanParam(name: 'ENABLE_DATABASE', defaultValue: true,  description: 'Deploy database resources?')
    booleanParam(name: 'ENABLE_REDIS',    defaultValue: false, description: 'Deploy Redis cache?')
    string(name: 'NODE_COUNT',      defaultValue: '2',         description: 'Number of VMs/nodes (1-50)')
  }

  environment {
    TF_IN_AUTOMATION       = 'true'
    TF_CLI_ARGS_init       = '-no-color'
    TF_CLI_ARGS_plan       = '-no-color'
    TF_CLI_ARGS_apply      = '-no-color -auto-approve'
    SONAR_TOKEN            = credentials('sonar-token')
    PROJECT_ROOT           = "${WORKSPACE}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Branch: ${GIT_BRANCH}, Commit: ${GIT_COMMIT}"'
      }
    }

    stage('Terraform Format Check') {
      steps {
        sh '''
          echo "==> Checking Terraform formatting..."
          terraform fmt -check -recursive . && echo "✅ Formatting OK" || {
            echo "❌ Format issues found. Run: terraform fmt -recursive ."
            exit 1
          }
        '''
      }
    }

    stage('Terraform Validate') {
      steps {
        script {
          def envs   = params.ENVIRONMENT == 'all' ? ['dev','qa','stage','prod'] : [params.ENVIRONMENT]
          def clouds = params.CLOUD        == 'all' ? ['aws','azure','gcp']       : [params.CLOUD]
          def failed = []
          for (env in envs) {
            for (cloud in clouds) {
              def dir = "environments/${env}/${cloud}"
              if (fileExists(dir)) {
                echo "Validating ${env}/${cloud}..."
                def rc = sh(script: """
                  cd ${dir}
                  terraform init -backend=false -no-color -input=false
                  terraform validate -no-color
                """, returnStatus: true)
                if (rc != 0) failed.add("${env}/${cloud}")
              }
            }
          }
          if (failed) error("Validation failed for: ${failed.join(', ')}")
        }
      }
    }

    stage('Security Scan (tfsec)') {
      steps {
        sh '''
          if ! command -v tfsec &>/dev/null; then
            echo "tfsec not found — skipping (install tfsec on Jenkins agent)"
          else
            tfsec . --minimum-severity MEDIUM --format junit --out tfsec-report.xml --no-color || true
          fi
        '''
      }
      post {
        always {
          script {
            if (fileExists('tfsec-report.xml')) {
              junit allowEmptyResults: true, testResults: 'tfsec-report.xml'
            }
          }
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh '''
            if command -v sonar-scanner &>/dev/null; then
              sonar-scanner \
                -Dsonar.projectVersion=$(cat versions/VERSION 2>/dev/null || echo "1.0.2") \
                -Dsonar.login=${SONAR_TOKEN}
            else
              echo "sonar-scanner not found — skipping (install sonar-scanner on Jenkins agent)"
            fi
          '''
        }
      }
      post {
        always {
          script {
            try {
              def qg = waitForQualityGate()
              if (qg.status != 'OK') {
                echo "⚠️  SonarQube Quality Gate: ${qg.status} (non-blocking)"
              }
            } catch (err) {
              echo "SonarQube gate check skipped: ${err.getMessage()}"
            }
          }
        }
      }
    }

    stage('Plan') {
      when { expression { params.ACTION in ['plan', 'apply'] } }
      steps {
        script {
          def envs   = params.ENVIRONMENT == 'all' ? ['dev','qa','stage','prod'] : [params.ENVIRONMENT]
          def clouds = params.CLOUD        == 'all' ? ['aws','azure','gcp']       : [params.CLOUD]
          for (env in envs) {
            for (cloud in clouds) {
              def dir = "environments/${env}/${cloud}"
              if (fileExists(dir)) {
                echo "Planning ${env}/${cloud}..."
                sh """
                  cd ${dir}
                  terraform init -no-color -input=false
                  terraform plan -no-color -input=false \
                    -var="compute_type=${params.COMPUTE_TYPE}" \
                    -var="vm_count=${params.NODE_COUNT}" \
                    -var="node_count=${params.NODE_COUNT}" \
                    -var="db_engine=${params.DB_ENGINE}" \
                    -var="enable_database=${params.ENABLE_DATABASE}" \
                    -var="enable_redis=${params.ENABLE_REDIS}" \
                    -out=tfplan
                """
              }
            }
          }
        }
      }
    }

    stage('Approval (stage/prod)') {
      when {
        allOf {
          expression { params.ACTION == 'apply' }
          expression { params.ENVIRONMENT in ['stage', 'prod', 'all'] }
        }
      }
      steps {
        input message: "🚀 Approve Terraform APPLY to ${params.ENVIRONMENT}/${params.CLOUD}?",
              ok: 'Approve',
              submitter: 'admin,devops-lead'
      }
    }

    stage('Apply') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        script {
          def envs   = params.ENVIRONMENT == 'all' ? ['dev','qa','stage','prod'] : [params.ENVIRONMENT]
          def clouds = params.CLOUD        == 'all' ? ['aws','azure','gcp']       : [params.CLOUD]
          for (env in envs) {
            for (cloud in clouds) {
              def dir = "environments/${env}/${cloud}"
              if (fileExists(dir)) {
                echo "Applying ${env}/${cloud}..."
                sh "cd ${dir} && terraform apply -no-color -auto-approve tfplan"
              }
            }
          }
        }
      }
    }

    stage('Destroy') {
      when { expression { params.ACTION == 'destroy' } }
      steps {
        input message: "⚠️  CONFIRM DESTROY for ${params.ENVIRONMENT}/${params.CLOUD}?",
              ok: 'Yes, Destroy',
              submitter: 'admin'
        script {
          def envs   = params.ENVIRONMENT == 'all' ? ['dev','qa','stage','prod'] : [params.ENVIRONMENT]
          def clouds = params.CLOUD        == 'all' ? ['aws','azure','gcp']       : [params.CLOUD]
          for (env in envs) {
            for (cloud in clouds) {
              def dir = "environments/${env}/${cloud}"
              if (fileExists(dir)) {
                sh """
                  cd ${dir}
                  terraform init -no-color -input=false
                  terraform destroy -no-color -auto-approve \
                    -var="compute_type=${params.COMPUTE_TYPE}" \
                    -var="vm_count=${params.NODE_COUNT}" \
                    -var="node_count=${params.NODE_COUNT}" \
                    -var="enable_database=${params.ENABLE_DATABASE}" \
                    -var="enable_redis=${params.ENABLE_REDIS}"
                """
              }
            }
          }
        }
      }
    }

    stage('Tag Release') {
      when {
        allOf {
          expression { params.ACTION == 'apply' }
          branch 'main'
        }
      }
      steps {
        sh 'bash scripts/bump-version.sh patch || echo "Version bump skipped (no changes)"'
      }
    }

  }

  post {
    always {
      archiveArtifacts artifacts: 'logs/**,**/tfsec-report.xml', allowEmptyArchive: true
    }
    failure {
      echo "❌ Pipeline FAILED — ${env.JOB_NAME} #${env.BUILD_NUMBER}"
      // emailext body: "Pipeline failed: ${env.BUILD_URL}", subject: "FAILED: ${env.JOB_NAME}", to: "devops@yourcompany.com"
    }
    success {
      echo "✅ Pipeline SUCCEEDED — ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }
  }
}
