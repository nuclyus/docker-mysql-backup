FROM phusion/baseimage
MAINTAINER Lysander Vogelzang <lysander@nuclyus.nl>

# Create a user for mysql, which is unified with the backuper
RUN useradd -u 5001 mysql

# Install MariaDB. We only need mysqldump, but it's only comes in the full package
RUN \
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xcbcb082a1bb943db && \
echo "deb http://mariadb.mirror.iweb.com/repo/10.0/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/mariadb.list && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server ftp && \
rm -rf /var/lib/apt/lists/*

# Make sure the log exists at first
RUN \
mkdir /backups && \
chown mysql:mysql /backups && \
chmod 750 /backups && \
touch /backups/backup.sql

# Add cronjob
ADD logrotate /etc/logrotate.d/mysql-backup

# Define mountable directories. (so we can retrieve the backups as well)
VOLUME ["/backups"]

# Define working directory.
WORKDIR /backups

# Define default command.
CMD ["/sbin/my_init"] 	
