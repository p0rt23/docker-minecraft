node {
    def port           
    def container_name
    def image_tag

    // https://www.minecraft.net/en-us/download/server/
    def image_name     = 'minecraft'
    def version        = 1.14.1
    def download_url   = 'https://launcher.mojang.com/v1/objects/ed76d597a44c5266be2a7fcd77a8270f1f0bc118/server.jar'
    
    if (env.BRANCH_NAME == 'master') {
        image_tag      = version
        container_name = image_name
        port           = 25565
    }
    else {
        image_tag      = "${version}-develop"
        container_name = "${image_name}-develop" 
        port           = 25566
    }

    world_volume   = "${container_name}-world"
    backups_volume = "${container_name}-backups"
 
    stage('Build') {
        checkout scm
        sh "curl -L -o server.jar ${download_url}"
        sh "docker build -t p0rt23/${image_name}:${image_tag} ."
    }

    stage('Deploy') {
        try {
            sh "docker stop ${container_name}"
            sh "docker rm ${container_name}"
        }
        catch (Exception e) { 
            
        }
        sh """
            docker run \
                -d \
                --restart always \
                --name ${container_name} \
                -v /home/docker/volumes/${world_volume}:/opt/${image_name}/world \
                -v /home/docker/volumes/${backups_volume}:/opt/${image_name}/backups \
                -p ${port}:25565 \
                p0rt23/${image_name}:${tag}
        """
    }
}
