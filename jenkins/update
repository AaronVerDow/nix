pipeline {
    agent any

    stages {
        stage('Flake Update') {
            steps {
                sh ''' 
		    git switch main
		    nix flake update
		'''
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
        stage('Push Update') {
            steps {
		sshagent(['329fefc4-6b34-4c35-941a-ba5fd1736773']) {
			sh '''
			  git status
			  git config --local user.email "jenkins@verdow.lan"
			  git config --local user.name "Jenkins"
			  git add flake.lock
			  git commit -m "auto update flake"
			  git status
			  git push
			'''
		}
            }
        }

   }
}
