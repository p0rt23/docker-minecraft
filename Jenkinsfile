node {
    def port           
    def container_name
    def image_tag
    def restart

    def image_name     = 'minecraft'
    def version        = '1.19.4'
    
    // https://www.minecraft.net/en-us/download/server/
    // def download_url   = 'https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar'
    
    // https://fabricmc.net/use/server/
    def download_url   = 'https://meta.fabricmc.net/v2/versions/loader/1.19.4/0.14.17/0.11.2/server/jar'
    
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
