#!/bin/bash

# Colores
green=`tput setaf 2`
red=`tput setaf 1`
reset=`tput sgr0`

# Banner
echo -e "$green--- FAVEO Community Setup ---$reset"

# Requiere 2 argumentos
if [[ $# -lt 4 ]]; then
    echo "Uso: $0 -domainname <dominio> -email <correo>"
    exit 1
fi

echo "Verificando requisitos..."
setenforce 0 2>/dev/null
apt update && apt install unzip curl git -y || yum install unzip curl git -y

if ! docker --version >/dev/null 2>&1; then
    echo "Docker no está instalado. Abortando."
    exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose no está instalado. Abortando."
    exit 1
fi

echo "Docker y Docker Compose encontrados."

# Argumentos
while test $# -gt 0; do
    case "$1" in
        -domainname)
            shift
            domainname=$1
            shift
            ;;
        -email)
            shift
            email=$1
            shift
            ;;
        *)
            echo "$1 no es un parámetro reconocido."
            exit 1
            ;;
    esac
done

# Confirmar
echo -e "\nDominio: $domainname"
echo -e "Email: $email\n"
read -p "¿Deseás continuar? (y/n): " REPLY
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# Variables
CUR_DIR=$(pwd)
host_root_dir="faveo"

# Clonar Faveo
if [ ! -d "$host_root_dir" ]; then
    echo "Descargando Faveo Helpdesk..."
    git clone https://github.com/ladybirdweb/faveo-helpdesk.git "$host_root_dir"
    if [[ $? -ne 0 ]]; then
        echo "Error al descargar Faveo."
        exit 1
    fi
fi

chown -R 33:33 "$host_root_dir"
find "$host_root_dir" -type d -exec chmod 755 {} \;
find "$host_root_dir" -type f -exec chmod 644 {} \;

# Generar contraseñas
db_root_pw=$(openssl rand -base64 12)
db_user_pw=$(openssl rand -base64 12)
db_name="faveo"
db_user="faveo"

# Configurar .env
cp -f example.env .env
sed -i "s:MYSQL_ROOT_PASSWORD=:MYSQL_ROOT_PASSWORD=$db_root_pw:" .env
sed -i "s/MYSQL_DATABASE=/MYSQL_DATABASE=$db_name/" .env
sed -i "s/MYSQL_USER=/MYSQL_USER=$db_user/" .env
sed -i "s:MYSQL_PASSWORD=:MYSQL_PASSWORD=$db_user_pw:" .env
sed -i "s/DOMAINNAME=/DOMAINNAME=$domainname/" .env
sed -i "s/HOST_ROOT_DIR=/HOST_ROOT_DIR=$host_root_dir/" .env
sed -i "s:CUR_DIR=:CUR_DIR=$CUR_DIR:" .env
echo "REDIS_HOST=faveo-Redis" >> .env

# Crear volumen y red
docker volume create --name ${domainname}-faveoDB
docker network rm ${domainname}-faveo 2>/dev/null
docker network create ${domainname}-faveo --driver=bridge --subnet=172.24.2.0/16

# Levantar contenedores
docker compose up -d

# Mostrar credenciales
if [[ $? -eq 0 ]]; then
    echo -e "\n$greenFaveo instalado correctamente.$reset"
    echo -e "URL: http://$domainname (redirigido por tu NGINX)"
    echo -e "\nCredenciales base de datos:"
    echo "DB Host: faveo-mariadb"
    echo "Root Password: $db_root_pw"
    echo "DB Name: $db_name"
    echo "DB User: $db_user"
    echo "User Password: $db_user_pw"
else
    echo -e "$redError al iniciar los contenedores.$reset"
    exit 1
fi