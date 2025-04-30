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
```bash
# Execution containers web
docker run -dt --name web-projet-1 -v $HOME/projet/web1/ --network web-projet1-net --network db-projet1-net web/project
docker run -dt --name web-projet-2 -v $HOME/projet/web2/ --network web-projet2-net --network db-projet2-net web/project
docker run -dt --name web-projet-3 -v $HOME/projet/web3/ --network web-projet3-net --network db-projet3-net web/project
```
```bash
# Execution contianers db
docker run -dt --name db-projet-1 --network db-projet1-net mariadb:11.7.2
docker run -dt --name db-projet-2 --network db-projet2-net mariadb:11.7.2
docker run -dt --name db-projet-3 --network db-projet3-net mariadb:11.7.2
```
```bash
# Execution container reverse-proxy
docker run -dt --name rproxy --network web-projet1-net --network web-projet2-net --network web-projet3-net -p 8080:80 rpoxy/projet
```
```bash
# Vérifier que l'architecture est déployée 
docker ps -a
```
# Déploiement automatique via Docker-Compose
S'il était souhaité déployer automatiquement l'architecture, l'utilisation d'un fichier compose serait pertinent
```bash
docker compose -f webservices-compose.yml up -d 
docker ps -a
```
L'entièreté de l'architecture est déployée y compris la création des networks. Il suffit de dpéloyer manuellement le proxy comment précedemment décrit afin d'avoir accès au site souhaité
