#!/bin/bash


# === CHANGE LOG ==============
# 2019-01-12 ##################
# rewrite of ytu.sh. due to loops and csv data, the data and youtube-dl commands can be manipulated much easier
# 2019-02-16 ##################
# made youtube-dl command dependent on nonfailed cd
# use stderr for error messages
# 2019-04-26 ##################
# added hidden file, documentation and UUID to improve mount check
# =============================


printf "Welcome to youtube-dl update script!\n"
printf "Python version: " && python --version
printf "youtube-dl version: " && youtube-dl --version
printf "Checking if drive 140715 is mounted...\n"

# use a hidden file with UUID to make sure that both the mount exists and that it is the desired filesystem
ytu_mount_check=`mktemp`
(cat /media/140715/.140715_mount_check_7e28b34c-6874-11e9-a923-1681be663d3e.txt | wc -l) 1> ${ytu_mount_check}

if [ -e "${ytu_mount_check}" ]; then
    if [ -f "${ytu_mount_check}" ]; then
        if [ -s "${ytu_mount_check}" ]; then
            printf "Mount check successful.\n"
        else
            printf "Mount check failed. Check file for drive 140715 exists, is a regular file, but is empty.\n" 1>&2
            exit 1
        fi
    else
        printf "Mount check failed. Check file for drive 140715 exists, but is not a regular file.\n" 1>&2
        exit 1
    fi
else
    printf "Mount check failed. Check file for drive 140715 does not exist for.\n" 1>&2
    exit 1
fi


# video
cd "/media/140715/039"
while IFS= read -r i; do
    channel_name=`echo "${i}" | cut -d';' -f1`
    channel_url=`echo "${i}" | cut -d';' -f2`
    cd "/media/140715/039/${channel_name}" && youtube-dl --download-archive archive.txt -f 'bestvideo[height<=1080]+bestaudio' --ignore-config --write-thumbnail -i -o "%(upload_date)s   %(title)s.%(ext)s" "${channel_url}"
done < ytu_video_channels.txt

# audio
cd "/media/140715/039"
while IFS= read -r i; do
    channel_name=`echo "${i}" | cut -d';' -f1`
    channel_url=`echo "${i}" | cut -d';' -f2`
    cd "/media/140715/039/${channel_name}" && youtube-dl -x --audio-format mp3 --download-archive archive.txt --ignore-config -i --embed-thumbnail -o "%(upload_date)s   %(title)s.%(ext)s" ${channel_url}
done < ytu_audio_channels.txt

printf "Finished updating youtube-dl directories!\n"
