pipeline {
    agent any

    stages {
        stage('Skip Flake Update') {
            steps {
                script {
                    def commitMessage = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()
                    
                    if (commitMessage.contains('auto flake update')) {
                        currentBuild.result = 'ABORTED'
                        error("Skipping flake update.")
                    }
                }
            }
        }
        stage('Games') {
            steps {
                sh 'nix build .#nixosConfigurations.games.config.system.build.toplevel'
            }
        }
        stage('Titanic') {
            steps {
                sh 'nix build .?submodules=1#nixosConfigurations.titanic.config.system.build.toplevel'
            }
        }
        stage('Gonix') {
            steps {
                sh 'nix build .#nixosConfigurations.gonix.config.system.build.toplevel'
            }
        }
        stage('IdeaPad') {
           steps {
               sh 'nix build .#nixosConfigurations.ipad.config.system.build.toplevel'
          }
      }
   }
}
