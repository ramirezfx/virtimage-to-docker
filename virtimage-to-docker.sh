#!/bin/bash

TEMPFILE=/tmp/virtdisk.tar.gz
BASEDIR=.
IMAGEFILE=$1
DOCKERTAG=$2

if [ "$EUID" -ne 0 ]
  then echo "Please run this script with sudo or run as root"
  exit 1
fi

GZIPPATH=$(which gzip)
DOCKERPATH=$(which docker)
LIBGUESTFS=$(which virt-tar-out)
KDIALOGPATH=$(which kdialog)

# Check if gzip is installed
if [ -z "$GZIPPATH" ]
then
 if [ -z "$KDIALOGPATH" ]
 then
  echo "Package gzip not installed. Aborting"
  exit 1
 else
  kdialog --error "Package gzip not installed. Aborting"
  exit 1 
 fi
fi

# Check if docker is installed
if [ -z "$DOCKERPATH" ]
then
 if [ -z "$KDIALOGPATH" ]
 then
  echo "Package docker.io not installed. Aborting"
  exit 1
 else
  kdialog --error "Package docker.io not installed. Aborting"
  exit 1
 fi
fi

# Check if libguestfs is installed
if [ -z "$LIBGUESTFS" ]
then
 if [ -z "$KDIALOGPATH" ]
 then
  echo "Package libguestfs not installed. Aborting"
  exit 1
 else
  kdialog --error "Package libguestfs not installed. Aborting"
  exit 1
 fi
fi

# Check if Docker-Tag was provided
if [ -z "$DOCKERTAG" ]
then
 if [ -z "$KDIALOGPATH" ]
  then
   echo "Input the docker-tag (ex. myapp:latest or mydockerhubusername/myapp:latest)"
   read DOCKERTAG
  else
  DOCKERTAG=$(kdialog --title "Please provide me with the docker-tag" --inputbox "Input the docker-tag. (ex.: myapp:latest or mydockerhubusername/myapp:latest")
 fi
fi

# Check if Docker-Tag is not empty
if [ -z "$DOCKERTAG" ]
then
 if [ -z "$KDIALOGPATH" ]
  then
   echo "No docker-tag provided. Abort now"
   exit 1
  else
  DOCKERTAG=$(kdialog --title "No Docker-Tag" --error "No Docker-Tag. Abort now")
  exit 1
 fi
fi

# Check if Image-File was provided
if [ -z "$IMAGEFILE"  ]
then
 if [ -z "$KDIALOGPATH"  ]
 then
  echo "No Image selected."
  echo "Usage: sudo ./virtimage-to-docker.sh /path/to/image."
  echo "Aborting"
  exit 1
 else
  IMAGEFILE=$(sudo kdialog --getopenfilename $BASEDIR) 
 fi
fi

# Check if Image-File was provided
if [ -z "$IMAGEFILE" ]
then
 if [ -z "$KDIALOGPATH" ]
 then
  echo "No Image-File Selected"
  echo "Aborting"
  exit 1
 else
  kdialog --error "No Image Selected. Aborting!"
  exit 1
 fi
fi

# Check if Image-File exists
if [ ! -f "$IMAGEFILE" ]
then
 if [ -z "$KDIALOGPATH" ]
 then
  echo "Image-File does not exist! Aborting"
  exit 1
 else
  kdialog --error "Image-File does not exist! Aborting"
  exit 1
 fi
fi

# Create Compressd Archive
virt-tar-out -a $IMAGEFILE / - | gzip --best > $TEMPFILE

# Import Compressed Archive to docker
cat $TEMPFILE | docker import - $DOCKERTAG

# Finished
if [ -z "$KDIALOGPATH" ]
then
 echo "Import to Docker finished"
else
 kdialog --msgbox "Import to Docker finished"
fi

# Cleanup
rm $TEMPFILE
