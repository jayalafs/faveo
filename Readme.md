## Faveo Helpdesk Docker

Un flujo de trabajo de Docker Compose bastante simplificado configura una red de contenedores para Faveo Helpdesk.
Todas las ediciones de Faveo Helpdesk son compatibles.

## Uso
___

Antes de empezar, asegúrese de tener Docker y docker-compose instalados en su sistema y luego clone este repositorio.

```sh
git clone https://github.com/ladybirdweb/faveo-helpdesk-docker-v2.git
```
---

A continuación, acceda a la terminal del directorio donde clonó este archivo y otorgue al ejecutable permisos para scripts de bash.

### Para todas las ediciones de Faveo (excepto la edición comunitaria):

```sh
chmod +x faveo-run.sh
```

### Para la edición comunitaria de Faveo:

```sh
chmod +x faveo-community-run.sh
```
---
## Requisitos para ejecutar el script:

Un nombre de dominio válido propagado completamente a la IP de su servidor.
Privilegios sudo.
Licencia de Faveo y número de pedido.
Puertos no reservados: 80 y 443. (Si están reservados, puede editar y cambiar los puertos que desee en docker-copompose.yml).
Sistemas operativos: CentOS 7, 8 o superior, y Ubuntu 16, 18 y 20.

## Para poner en funcionamiento los contenedores, siga las instrucciones a continuación. ---
### Ejecute el script "faveo-run.sh" pasando los argumentos necesarios para las ediciones de Faveo (excepto Faveo Community Edition).

Nota: Debe tener un nombre de dominio válido que apunte a su IP pública. Este nombre de dominio se utiliza para obtener certificados SSL de Let's Encrypt CA, y el correo electrónico se utiliza para el mismo propósito. El código de licencia y el número de pedido se pueden obtener en el portal de facturación del servicio de asistencia de Faveo. Asegúrese de no incluir el carácter "#" en el número de pedido.

Uso:
```sh
./faveo-run.sh -domainname <your domainname> -email <example@email.com> -license <faveo license code> -orderno <faveo order number>
```
Ejemplo: Debería verse así. ```sh
./faveo-run.sh -domainname berserker.tk -email berserkertest@gmail.com -license 5H876********** -orderno 8123******
```
### Ejecute el script "faveo-community-run.sh" pasando los argumentos necesarios para Faveo Community Edition.

Nota: Debe tener un nombre de dominio válido que apunte a su IP pública. Este nombre de dominio se utiliza para obtener certificados SSL de Let's Encrypt CA, y el correo electrónico se utiliza para el mismo propósito.

Uso:
```sh
./faveo-community-run.sh -domainname <your domainname> -email <example@email.com>
```
Ejemplo: Debería verse así. ```sh
./faveo-community-run.sh -domainname berserker.tk -email berserkertest@gmail.com
```
---
Tras completar la instalación de Docker, se le solicitarán las credenciales de la base de datos, que deberá copiar y guardar en un lugar seguro, y una tarea cron para renovar automáticamente los certificados SSL de Let's Encrypt.

Visite https://yourdomainname, complete la prueba de preparación, introduzca la información de la base de datos cuando se le solicite y finalice la instalación.

Un último paso antes de completar la instalación es editar el archivo .env, que se genera en el directorio raíz de Faveo tras completar el proceso de instalación en el navegador. Abra una terminal y navegue hasta el directorio faveo-docker. Allí encontrará el directorio "faveo", que se descarga al ejecutar el script. Este directorio contiene todo el código base del Helpdesk. Debe editar el archivo ".env" y agregar REDIS_HOST=faveo-Redis. "faveo-redis" es el nombre DNS del contenedor Redis. Finalmente, ejecute el siguiente comando para que los cambios surtan efecto.

```sh
docker compose down && docker compose up -d
```