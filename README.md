# Docker_LXC_Project (Réalisé seul : Emmanuel)
```bash
# Construction des diverses images à partir des fichiers Dockerfile-Web et Nginx   ( se situer dans le dossier Dockerfile pour l'exécution de la commande)
docker build -f Dockerfile-Web -t web/project .
docker build -f Dockefile-Nginx -t rproxy/project .

```
# Deploiement via commandes docker run 
 S'il était souhaité déployer manuellement l'architecture, les commandes suivantes seraient à entrer:
```bash
# Créer les networks
docker network create web-projet1-net 
docker network create web-projet2-net
docker network create web-projet3-net
docker network create db-projet1-net
docker network create db-projet2-net
docker network create db-projet3-net
```
Créer trois dossiers : web1, web2, web3
```bash
mkdir web1, web2, web3
```
```bash
# Execution containers web
docker run -dt --name web-projet-1 -v $HOME/projet/web1/:/var/www/html --network web-projet1-net --network db-projet1-net web/project
docker run -dt --name web-projet-2 -v $HOME/projet/web2/:/var/www/html --network web-projet2-net --network db-projet2-net web/project
docker run -dt --name web-projet-3 -v $HOME/projet/web3/:/var/www/html --network web-projet3-net --network db-projet3-net web/project
```
```bash
# Execution contianers db
docker run -dt --name db-projet-1 --network db-projet1-net --env MARIADB_ROOT_PASSWORD=example mariadb:11.7.2
docker run -dt --name db-projet-2 --network db-projet2-net --env MARIADB_ROOT_PASSWORD=example mariadb:11.7.2
docker run -dt --name db-projet-3 --network db-projet3-net --env MARIADB_ROOT_PASSWORD=example mariadb:11.7.2
```
Créer un dossier rproxy
```bash
mkdir ~/rproxy
```
Ajout fichier index.html à chaque web container afin de différencier les trois projets
```bash
PROJET1=Bienvenue sur le projet 1
PROJET2=Bienvenue sur le projet 2 
PROJET3=Bienvenue sur le projet 3
echo "$PROJET1" > $HOME/web1/index.html && echo "$PROJET2" > $HOME/web2/index.html && echo "$PROJET3" > $HOME/web3/index.html
```
# Execution container reverse-proxy
```bash
docker run -dt --name rproxy -v $HOME/projet/rproxy:/etc/nginx/ --network web-projet1-net --network web-projet2-net --network web-projet3-net -p 8080:80 rpoxy/projet
```
Configuration du proxy pour redirection de traffic vers les services correspondants
```bash
#Dans le dossier sites-enabled, créer un fichier reverse.conf
server{

        listen 80;
        server_name web-projet1.local;
        location / {
                proxy_pass http://web-projet1;
        }
}
server{

        listen 80;
        server_name web-projet2.local;

        location / {
                proxy_pass http://web-projet2;
        }
}
server{

        listen 80;
        server_name web-projet3.local;

        location / {
                proxy_pass http://web-projet3;
        }
}

#Suppression du fichier par défaut afin d'éviter de possibles erreurs
rm $HOME/rproxy/sites-enabled/default
#Vérifier que le fichier est correct pour nginx et reload
docker exec rproxy nginx -t
docker exec rproxy nginx -s reload 
#Modifier le fichier hosts de la machine hôte afin que les redirections s'établissent
printf "127.0.0.1 web-projet1.local\n127.0.0.1 web-projet2.local\n127.0.0.1 web-projet3.local" >> /etc/hosts  
```
```bash
# Vérifier que l'architecture est déployée 
docker ps -a
```
# Déploiement automatique via Docker-Compose
S'il était souhaité déployer automatiquement l'architecture, l'utilisation d'un fichier compose serait pertin
nt
```bash
docker compose -f webservices-compose.yml up -d 
docker ps -a
```
L'entièreté de l'architecture est déployée y compris la création des networks. Il suffit de dpéloyer manuellement le proxy comment précedemment décrit afin d'avoir accès au site souhaité
# Déploiement automatique LXC
Le script à exécuter ci-après détaille le déploiement automatique d'une infrastructure LXC containers simple (3 serveurs web, 3 bases de données), une entrée utilisateur est attendue définissant le nom à donner aux containers et le mot de passe à definir pour MariaDB
```bash
sudo chmod +x ./auto_deploy_lxc.sh
mkdir -p $HOME/shared-files-lxd
sudo ./auto_deploy_lxc.sh
```

