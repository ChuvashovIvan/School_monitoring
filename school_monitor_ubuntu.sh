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
echo -e $BOLD$BLUE"Настройка PGWatch2

"$RESET


PGPATH=/usr/lib/postgresql/14/bin
PGDATA=/var/lib/postgresql/14/

rm -rf /etc/apt/keyrings/docker.gpg
docker kill $(docker ps -q) > /dev/null 2>&1
docker rm $(docker ps -a -q) > /dev/null 2>&1
docker rmi $(docker images -q) > /dev/null 2>&1
pause "Начинаем...
"

clear
echo -e $BOLD$BLUE"
1. Мы зашли на стенд. Проверяем установленные пакеты."$RESET

pause "		apt list --installed | grep postgres
"
apt list --installed | grep postgres

echo -e $BOLD$BLUE"
2. Инициализируем кластер"$RESET

pause "		pg_dropcluster 14 main --stop
		pg_createcluster 14 main 
"
pg_dropcluster 14 main --stop
pg_createcluster 14 main 

echo -e $BOLD$BLUE"
3. Прежде чем запустить кластер, меняем конфигурацию PostgreSQL. Запускаем кластер
"$RESET

pause "		echo \"listen_addresses = '*'\" >> /etc/postgresql/14/main/postgresql.conf
		echo \"host    all             all             0.0.0.0/0               trust\" >> /etc/postgresql/14/main/pg_hba.conf
		pg_ctlcluster 14 main start
"
echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf
echo "host    all             all             0.0.0.0/0               trust" >> /etc/postgresql/14/main/pg_hba.conf
pg_ctlcluster 14 main start

echo -e $BOLD$BLUE"
4. Проверяем состояние базы данных"$RESET
pause "		pg_ctlcluster 14 main status
"
pg_ctlcluster 14 main status

echo -e $BOLD$BLUE"
4. Обновляем apt-get update и ставим пакеты для докера"$RESET

pause "		sudo apt-get update
		sudo apt-get install ca-certificates curl gnupg
		sudo install -m 0755 -d /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		sudo chmod a+r /etc/apt/keyrings/docker.gpg
		echo \
  		  deb [arch=\"$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  		$(. /etc/os-release && echo \$VERSION_CODENAME) stable | \
  		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt-get update
		sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
"

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


echo -e $BOLD$BLUE"
5. Скачиваем докер образ и запускаем pgwatch2"$RESET

pause "		docker run --rm -d -p 3000:3000 -p 8080:8080 -e PW2_TESTDB=true --name pgwatch2 cybertec/pgwatch2
"

docker run --rm -d -p 3000:3000 -p 8080:8080 -e PW2_TESTDB=true --name pgwatch2 cybertec/pgwatch2

echo -e $BOLD$BLUE"
6. Проверяем, что образ запустился"$RESET

pause "		docker ps
"

docker ps

echo -e $BOLD$BLUE"
7. Устанавливаем расширения для pgwatch2"$RESET
pause "		/opt/practice/all_metrics/run_all_db.sh
"

/opt/practice/all_metrics/run_all_db.sh

echo -e $BOLD$BLUE"
8. Запускаем pgbench на 30 минут"$RESET
pause "		/usr/lib/postgresql/14/bin/pgbench -i
		/usr/lib/postgresql/14/bin/pgbench -T600
"

sudo -iu postgres /usr/lib/postgresql/14/bin/pgbench -i
sudo -iu postgres /usr/lib/postgresql/14/bin/pgbench -T600

echo -e $BOLD$BLUE"
10. Идем в браузер"$RESET

echo -e $BOLD$BLUE"Конец демонстрации"$RESET
pause ""
pause ""
