#!/usr/bin/bash
# FÜRS SETUP siehe setup.sh !!!
# siehe https://wiki.archlinux.org/title/Davfs2 fuer mehr infos


source ${BASH_SOURCE%/*}/utils.sh
source ${BASH_SOURCE%/*}/config.sh


# function for mounting the subject

function mounte_webordner { # arg1 : Name arg2: ref_number

    if ! mountpoint -q  $MOUNT_DIRECTORY/$1; then

    printf "mounte $1 \n"
    sudo mount -t davfs https://www.ilias.fh-dortmund.de/ilias/webdav.php/ilias-fhdo/ref_$2  $MOUNT_DIRECTORY/$1
                        #add your own uni webdav link here
    fi
}


# function for copying all the new files to destination folder
function copy_stuff { # 1 argument => Name

echo -e "\033[33mBeginne Datei aus $1 zu kopieren... \033[0m\n"
rsync  -rtu --ignore-existing --out-format='neue Datei: %n' --exclude 'lost+found/' $MOUNT_DIRECTORY/$1/    $DESTINATION_FOLDER/$1/  | sed '/^neue Datei:.*\/$/d'
echo -e "\033[32mKopiervorgang für $1 abgeschlossen! \033[0m\n"

}




### 
while read line; do
    if [[ ! $line = \#* ]]; then   # if not a comment read line
    w_counter=0
    for word in $line; do
        if [[ $w_counter -eq 0 ]]; then   # first word is the name of the subject
            name=$word
#            echo Name=$word
        fi

        if [[ $w_counter -eq 1 ]]; then  # second word is the ref number
            ref=$word
#            echo $name  ==  $ref
            mounte_webordner $name $ref
            copy_stuff $name

        fi
        let w_counter=w_counter+1

        done

    fi
done <  ${BASH_SOURCE%/*}/kurse.ini

# I have a nextcloud installation on my server, so I init a nextcloud file scan at the end
# the files will be than synced to my laptop by nextcloud
echo updating nextcloud index
sudo -u nextcloud php8.0 --define apc.enable_cli=1 /var/www/nextcloud/occ files:scan --all


