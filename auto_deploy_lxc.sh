#!/bin/bash

APACHE_COUNT=3
DB_COUNT=3
APACHE_IMAGE="ubuntu:22.04"
DB_IMAGE="ubuntu:22.04"


read -p " Nom de base des conteneurs Apache (ex: web) : " APACHE_BASE
read -p " Nom de base des conteneurs MariaDB (ex: db)   : " DB_BASE
read -s -p " Mot de passe root MariaDB à utiliser : " MYSQL_ROOT_PASSWORD
echo


create_container() {
    NAME=$1
    IMAGE=$2
    echo "  Création du conteneur $NAME..."
    lxc launch "$IMAGE" "$NAME"
}

install_apache() {
    NAME=$1
    echo " Installation Apache2 dans $NAME..."
    lxc exec "$NAME" -- bash -c "apt-get update && apt-get install -y apache2 && systemctl enable apache2 && systemctl start apache2"

}

install_mariadb() {
    NAME=$1
    echo " Installation MariaDB dans $NAME..."
    lxc exec "$NAME" -- bash -c "
        apt-get update &&
        DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server expect &&
        systemctl enable mariadb &&
        systemctl start mariadb
    "

    echo " Sécurisation MariaDB avec mot de passe root..."

    lxc exec "$NAME" -- bash -c 'expect <<EOF
spawn mysql_secure_installation

expect "Enter current password for root (enter for none):"
send "\r"

expect "Switch to unix_socket authentication"
send "n\r"

expect "Change the root password?"
send "y\r"

expect "New password:"
send "'"$MYSQL_ROOT_PASSWORD"'\r"

expect "Re-enter new password:"
send "'"$MYSQL_ROOT_PASSWORD"'\r"

expect "Remove anonymous users?"
send "y\r"

expect "Disallow root login remotely?"
send "y\r"

expect "Remove test database and access to it?"
send "y\r"

expect "Reload privilege tables now?"
send "y\r"

expect eof
EOF'
}

for i in $(seq 1 $APACHE_COUNT); do
    NAME="${APACHE_BASE}${i}"
    create_container "$NAME" "$APACHE_IMAGE"
    sleep 5
    install_apache "$NAME"
    sudo lxc config device add "$NAME" "$NAME" disk source=$HOME/shared-files-lxd/ path=/var/www/html/

done


#for i in $(seq 1 $DB_COUNT); do
#    NAME="${DB_BASE}${i}"
#    create_container "$NAME" "$DB_IMAGE"
#    sleep 5
#    install_mariadb "$NAME"
#done

echo "Lancement du conteneur Docker proxy..."

sudo docker rm -f rproxy 2>/dev/null

IP1=$(lxc list "${APACHE_BASE}1" -c 4 --format csv | awk '{print $1}')
IP2=$(lxc list "${APACHE_BASE}2" -c 4 --format csv | awk '{print $1}')
IP3=$(lxc list "${APACHE_BASE}3" -c 4 --format csv | awk '{print $1}')

sudo docker run -dt --name rproxy \
  --add-host web-projet1:$IP1 \
  --add-host web-projet2:$IP2 \
  --add-host web-projet3:$IP3 \
  -p 8080:80 rproxy/project


echo "Déploiement terminé avec succès."

