# Server Setup v.1.0.2

# How to setup server?
# curl -O -L https://raw.githubusercontent.com/ivanblazevic/deploy-docker-service/master/server-setup.sh
# chmod +x server-setup.sh
# ./server-setup.sh
# Follow the instructions....

echo "Setting up the server..."

# Setup GitHub
echo "Install GitHub actions, follow: https://github.com/organizations/preformator/settings/actions/add-new-runner?arch=x64&os=linux"
echo $'Run GitHub actions as a service:\n./svc.sh install\n./svc.sh start'
read -r -p "Are GitLab actions installed and running as a service? [Y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Proceeding..."
else
    echo "Setup GitHub actions in order to proceed further."
    exit 1
fi

# Install docker
echo "Installing docker..."
if ! command -v docker &> /dev/null
then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    docker swarm init
    echo "Done."
else
    echo "Docker already installed, skipping..."
fi

# Setup registry
echo "Creating docker registry.."

docker service create --with-registry-auth --name registry -d -p 5000:5000 registry:2
echo "Done."

# docker exec -it 39538f0d5f17 /bin/bash

# Setup max number of file watcher as we are getting following error:
# "Error: ENOSPC: System limit for number of file watchers reached, watch '/public/tmp/448.json'"
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
    
echo "Setting up postgres service, creating working directory..."
mkdir $HOME/postgres-data

echo "Backup directory with following command: tar -zcvf postgres-data.tar.gz $HOME/postgres-data"
echo "Restore backup with following command: tar -zxvf postgres-data.tar.gz"

read -r -p "Did you restored postgres data into $HOME/postgres-data ? [Y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Proceeding..."

    echo "Setting up portiner"
    mkdir $HOME/portainer_data
    docker service create --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock --mount type=bind,source=$HOME/portainer_data,destination=/data --name portainer --publish published=9000,target=9000 portainer/portainer

    echo "Done, access HOST:9000 to check services"
else
    echo "Restore postgres data before continuing."
    exit 1
fi

echo "Enter postgres password"
read POSTGRES_PASSWORD
docker service create --name dev-postgres -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -p 5432:5432 --mount type=bind,source=$HOME/postgres-data,destination=/var/lib/postgresql/data postgres

echo "Server setup is completed."