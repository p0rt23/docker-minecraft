node {
    def port           
    def container_name
    def image_tag
    def restart

    // https://www.minecraft.net/en-us/download/server/
    def image_name     = 'minecraft'
    def version        = '1.17.1'
    def download_url   = 'https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar'
    
    if (env.BRANCH_NAME == 'master') {
        image_tag      = version
        container_name = image_name
        port           = 25565
        restart        = "always"
        docker_cmd     = "run"
        detatched      = "-d"
    }
    else {
        image_tag      = "${version}-develop"
        container_name = "${image_name}-develop" 
        port           = 25566
        restart        = "no"
        docker_cmd     = "create"
        detatched      = ""
    }

    def world_volume = "${container_name}-world"
    def logs_volume  = "${container_name}-logs"
 
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
            docker ${docker_cmd} \
                ${detatched} \
                --restart ${restart} \
                --name ${container_name} \
                --network="minecraft" \
                -v ${world_volume}:/opt/${image_name}/world \
                -v ${logs_volume}:/opt/${image_name}/logs \
                -p ${port}:25565 \
                p0rt23/${image_name}:${image_tag}
        """
    }
}
