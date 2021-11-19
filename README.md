##My Wikijs !
This project is meant to track changes in the files I need in order to run Wikijs on docker, on any host I want.

To start the wiki I must use the command 
WHOAMI="$(whoami)" docker-compose up

i.e. I need to pass the variable WHOAMI with the name of my home directory. This variable is needed in the mapping of an ssh key from the host (see below), in the docker file.

The wiki application (shortly 'the application') runs as a microservices application with two containers, one for the application itself and another for the db which stores all the wiki pages data. See the docker file. 
The images from which the container are started are:
- cml87/wikijs_db:nano  // for the db
- cml87/wikijs_app:nano // for the web app itself

These are in my DockerHub account, and are based on the original wikijs app images: postgres:11-alpine and requarks/wiki:2.
I built my images from the original ones, after updating the OS and installing some missing programs like nano.

The admin user and password set in these images for the application are: admin@example.com/admin*

The data the wiki uses is stored in a postgres db. The wiki mounts the data dir of the db in a volume called 'wikijs-db_vol'. Moreover, the container with the app internaly mantains
a git repository, with a GitHub remote: git@github.com:cml87/wikijs_backup.git. This respository will be local to the wiki app container, it will not exist in the host. It's not needed, as all I want is to keep the data in my GitHub account, and this can be achieved directly from the app container.

The app container is configured to automatically make pushes to the GitHub remote, so data is constantly backed up on this project of my GitHub account. 
The direction for this sincronization is set to "Push to target", in the configuration of the application (app container). This means 
that the app will only push data towards the remote, never in the oposite direction. In order to do these pushes however, the app container needs and ssh private key called wikijs_app-sshkey, which I bind-mount from the host. I'm the only one with access to this key. In the administration part of the wiki it's possible to manually perform the following actions:

Add Untracked Changes: Output all content from the DB to the local Git repository to ensure all untracked content is saved. If you enabled Git after content was created or you temporarily disabled Git, you'll want to execute this action to add the missing untracked changes.
Force Sync: Will trigger an immediate sync operation, regardless of the current sync schedule. The sync direction is respected.
Import Everything: Will import all content currently in the local Git repository, regardless of the latest commit state. Useful for importing content from the remote repository created before git was enabled.
Purge Local Repository: If you have unrelated merge histories, clearing the local repository can resolve this issue. This will not affect the remote repository or perform any commit.

I think that the Import Everithing action what does is to take what is in the local git repo and pass it to the db.

In order to fetch the data in a new host, therefore, I think I could temporarily set the syncronization direction to "Pull from target", run a "Force Sync" and then a " Import Everithing".


I will keep the key needed to make the pushes to the remote, as well as a backup of the db, in my google drive. If the public key in the drive seems to not work, the do 
https://www.howtogeek.com/168119/fixing-warning-unprotected-private-key-file-on-linux/

The git repo will store all pages of the wiki separately, so they can be seen directly if needed. That's how it's useful. However, the inteded way to import data into a new host is to download the backup volume from my drive and mount it in the data directory the db container needs.


##Backup and restore wiki data

The data for the pages displayed in the wiki is stored in a postgresql db. The data foleder for this db is in the db container of the application at /var/lib/postgresql/data. This is the directory I will backup as data.tar.gz

###Backup data

The backup file data.tar.gz will be created through the script backup_my_wiki.sh. This script works by ...

###Restore data

To restore the wiki data from the file data.tar.gz I need to extract its content directly into a volume called wikijs-db_vol, as this volume is mounted into the data directory of the db container of the application, /var/lib/postgresql/data. This will be achieved by means of the script restore_my_wiki.sh. This script works by ...




docker run --rm --volumes-from datavolume-name -v $(pwd):/backup image-name tar cvf  backup.tar /path-to-datavolume

docker run --rm --volumes-from datavolume-name -v $(pwd):/backup image-name bash -c "cd /path-to-datavolume && tar xvf /backup/backup.tar --strip 1"



(CONTAINER=myproject_db_1 REMOTE_HOST=newhost DIR=/var/lib/mysql; \
    docker run --rm \
    --volumes-from "$(docker inspect --format={{.Id}} $CONTAINER)" \
    busybox tar -czv --to-stdout $DIR  \
   


    | ssh $REMOTE_HOST docker run --rm -i \
    --volumes-from "\$(docker inspect --format={{.Id}} $CONTAINER)"\
    busybox tar -xzv \
    )

________

A backup can be get with the following command

docker run --rm --volumes-from wikijs_db -v $(pwd):/backup ubuntu bash -c "cd /var/lib/postgresql && tar -zcvf /backup/data.tar.gz data"

Here we mount the same volume as the db container of the wiki, as well as the current directory at /backup of the started container (ubuntu). We then run tar to compress the content of 
the directory with the data into a file at the directory mounted with -v. Onece the tar command finishes the container stops and is removed (--rm option).


