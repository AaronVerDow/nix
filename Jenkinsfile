pipeline {
    agent any

    stages {
        stage('Cache Test') {
            steps {
                sh 'nix build .#nixosConfigurations.gonix.config.system.build.toplevel'
            }
        }
    }
}
