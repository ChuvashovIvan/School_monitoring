#!/bin/bash
# init

RESET="\033[0m"
BOLD="\033[1m"
YELLOW="\033[38;5;11m"
BLUE="\033[36m"

function pause(){
   read -p "$(echo -e $BOLD$YELLOW"$* "$RESET)"
}
clear
echo -e $BOLD$BLUE"Мониторинг PostgreSQL

"$RESET
echo -e $BOLD$BLUE"Настройка pgwatch2

"$RESET


PGPATH=/usr/pgsql-15/bin
PGDATA=/var/lib/pgsql/15

if [ -f ${PGDATA}/data/postgresql.conf ]; then
        if [ -f ${PGDATA}/data/postmaster.pid ]; then
                 sudo -u postgres -i ${PGPATH}/pg_ctl -D ${PGDATA}/data stop > /dev/null 2>&1
        fi;
        rm -rf ${PGDATA}/data/*
fi

docker kill $(docker ps -q) > /dev/null 2>&1
docker rm $(docker ps -a -q) > /dev/null 2>&1
docker rmi $(docker images -q) > /dev/null 2>&1
pause "Начинаем...
"

clear

echo -e $BOLD$BLUE"
1. Инициализируем кластер"$RESET

pause "		${PGPATH}/pg_ctl -D ${PGDATA}/data initdb
"
sudo -iu postgres ${PGPATH}/pg_ctl -D ${PGDATA}/data initdb

echo -e $BOLD$BLUE"
2. Прежде чем запустить кластер, меняем конфигурацию PostgreSQL. Запускаем кластер
"$RESET

pause "		echo \"listen_addresses = '*'\" >> ${PGDATA}/data/postgresql.conf
		echo \"host    all             all             0.0.0.0/0               trust\" >> ${PGDATA}/data/pg_hba.conf
		${PGPATH}/pg_ctl -D ${PGDATA}/data start
"
echo "listen_addresses = '*'" >> ${PGDATA}/data/postgresql.conf
echo "host    all             all             0.0.0.0/0               trust" >> ${PGDATA}/data/pg_hba.conf
sudo -iu postgres ${PGPATH}/pg_ctl -D ${PGDATA}/data start

echo -e $BOLD$BLUE"
3. Проверяем состояние базы данных"$RESET
pause "		${PGPATH}/pg_ctl -D ${PGDATA}/data status
"
sudo -iu postgres ${PGPATH}/pg_ctl -D ${PGDATA}/data status

echo -e $BOLD$BLUE"
4. Ставим пакеты для докера"$RESET

pause "		sudo yum install -y yum-utils
		sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
"
sudo yum install -y yum-utils
		sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e $BOLD$BLUE"
5. Скачиваем докер образ и запускаем pgwatch2"$RESET

pause "		docker run --rm -d -p 3000:3000 -p 8080:8080 -e PW2_TESTDB=false --name pgwatch2 cybertec/pgwatch2
"

docker run --rm -d -p 3000:3000 -p 8080:8080 -e PW2_TESTDB=false --name pgwatch2 cybertec/pgwatch2

echo -e $BOLD$BLUE"
6. Проверяем, что образ запустился"$RESET

pause "		docker ps
"

docker ps

echo -e $BOLD$BLUE"
7. Устанавливаем расширения для pgwatch2"$RESET
pause "		/opt/all_metrics/run_all_db.sh
"

/opt/all_metrics/run_all_db.sh

echo -e $BOLD$BLUE"
8. Идем в браузер"$RESET

echo -e $BOLD$BLUE"Конец демонстрации"$RESET
pause ""
pause ""