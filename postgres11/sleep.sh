#!/bin/bash
if [ -z "$(ls -A /d01/postgres/11 )" ];
then
chown -R postgres:postgres /d01/postgres/11
su - postgres -c "/usr/lib/postgresql/11/bin/initdb -E UTF8 -D /d01/postgres/11/"
echo "host all all 0.0.0.0/0 md5" >> /d01/postgres/11/pg_hba.conf
echo "listen_addresses = '*'" >> /d01/postgres/11/postgresql.conf
su - postgres -c "/usr/lib/postgresql/11/bin/pg_ctl -W -D /d01/postgres/11 start"
psql -U postgres -d postgres --command="CREATE ROLE zabbix PASSWORD 'zabbix' SUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN;"
psql -U postgres -d postgres --command="CREATE DATABASE zabbix OWNER = zabbix ;"


else 
	echo "baza on the board"
su - postgres -c "/usr/lib/postgresql/11/bin/pg_ctl -W -D /d01/postgres/11 start"
fi


sleep infinity
