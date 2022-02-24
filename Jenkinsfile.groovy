pipeline {
    agent any
    stages {
        stage('update templates') {
            steps {
                script {
                    final branch = env.GIT_BRANCH
                    println "Current branch is $branch"
                    if (branch == 'air') {
                        withEnv(['KEYCLOAK_USER_CLIENT_SECRET=2b5dcb7d-5807-455f-ad0d-b479c583f3c8',
                                 'KEYCLOAK_USER_CLIENT_ID=damba-test',
                                 'KEYCLOAK_USER=****',
                                 'KEYCLOAK_PASS=****',
                                 'REPORT_MANAGER_BASE_URL=http://reports:8081',
                                 'KEYCLOAK_BASE_URL=https://keycloak.dev.g42a.ae',
                                 'KEYCLOAK_USER_REALM=g42a']) {
                            sh './script.sh'
                        }
                    } else if (branch == 'water') {
                        withEnv(['KEYCLOAK_USER_CLIENT_SECRET=2b5dcb7d-5807-455f-ad0d-b479c583f3c8',
                                 'KEYCLOAK_USER_CLIENT_ID=damba-test',
                                 'KEYCLOAK_USER=****',
                                 'KEYCLOAK_PASS=****',
                                 'REPORT_MANAGER_BASE_URL=http://reports:8081',
                                 'KEYCLOAK_BASE_URL=https://keycloak.dev.g42a.ae',
                                 'KEYCLOAK_USER_REALM=g42a']) {
                            sh './script.sh'
                        }
                    } else if (branch == 'union') {
                        withEnv(['KEYCLOAK_USER_CLIENT_SECRET=2b5dcb7d-5807-455f-ad0d-b479c583f3c8',
                                 'KEYCLOAK_USER_CLIENT_ID=damba-test',
                                 'KEYCLOAK_USER=****',
                                 'KEYCLOAK_PASS=****',
                                 'REPORT_MANAGER_BASE_URL=http://reports:8081',
                                 'KEYCLOAK_BASE_URL=https://keycloak.dev.g42a.ae',
                                 'KEYCLOAK_USER_REALM=g42a']) {
                            sh './script.sh'
                        }
                    } else if (branch == 'earth') {
                        withEnv(['KEYCLOAK_USER_CLIENT_SECRET=2b5dcb7d-5807-455f-ad0d-b479c583f3c8',
                                 'KEYCLOAK_USER_CLIENT_ID=damba-test',
                                 'KEYCLOAK_USER=****',
                                 'KEYCLOAK_PASS=****',
                                 'REPORT_MANAGER_BASE_URL=http://reports:8081',
                                 'KEYCLOAK_BASE_URL=https://keycloak.dev.g42a.ae',
                                 'KEYCLOAK_USER_REALM=g42a']) {
                            sh './script.sh'
                        }
                    } else {
                        println "No env variables found for branch: $branch"
                    }
                }
            }
        }
    }
}
