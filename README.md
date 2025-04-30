# Docker_LXC_Project
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
```
```bash
# Executer les containers à partir des image précedemment créées
docker run -dt --name rproxy --network web-projet1-net --network web-projet2-net --network web-projet3-net -p 8080:80 rpoxy/projet
```
