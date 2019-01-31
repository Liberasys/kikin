#!/bin/bash
# Copyright : Liberasys (HUSSON CONSULTING SAS) - 201702 - Gautier HUSSON

# TODO : user input validation, user preexistance verification, user key directory preexistance verification

BASEUID="2000"
USERSDBDIR="user_present/"
DATEHOUR=$(date "+%Y%m%d-%H%M%S")
USER_NEXT_UID_FILEPATH="$USERSDBDIR/next_uid.txt"
AINVENTORYALL="inventory/all.inventory"

echo "Ansible KIKIN"
echo "Copyright (C) 2017  Gautier HUSSON, for HUSSON CONSULTING SAS (Liberasys)"
echo "This program comes with ABSOLUTELY NO WARRANTY; for details,"
echo "read README.txt file."
echo "    This is free software, and you are welcome to redistribute it"
echo "    under certain conditions; read license.txt file for details."
echo ""

if [[ ! -e $USERSDBDIR ]]; then
  mkdir --parents $USERSDBDIR
elif [[ ! -d $USERSDBDIR ]]; then
  echo "$USERSDBDIR already exists but is not a directory" 1>&2
  exit 1
fi

if [[ ! -f $USER_NEXT_UID_FILEPATH ]]; then
    echo "$BASEUID" > $USER_NEXT_UID_FILEPATH
fi

USER_NEXT_UID=$(cat ${USER_NEXT_UID_FILEPATH})

# ask for user NAME and Surname
unset USERNAMESURNAME
while [[ $USERNAMESURNAME == '' ]]
do
    read -p "Enter user NAME and Surname (ex : HUSSON Gautier): " USERNAMESURNAME
    NORMALISED_USERNAME=$(echo ${USERNAMESURNAME} | tr -s ' ' | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | tr -cd '[[:alnum:]]._-')
    USERDBFILEPATH="${USERSDBDIR}/${NORMALISED_USERNAME}.yml"
    USERKEYSDIR="$(echo $USERSDBDIR )/$NORMALISED_USERNAME/"
    USERKEYSDIR=$(echo $USERKEYSDIR | tr -s '/')
    if [ -e $USERDBFILEPATH ] || [ -e $USERKEYSDIR ]; then
      echo "Normalised username already used : \"${NORMALISED_USERNAME}\", please differentiate the user NAME/Surname."
      echo
      unset USERNAMESURNAME
    fi
done

# ask for user company
unset USERCOMPANY
while [[ $USERCOMPANY == '' ]]
do
    read -p "Enter user Company: " USERCOMPANY
done

# ask for user login
unset USERLOGIN
USERNAMEPROP=$(echo ${USERNAMESURNAME} | cut -d " " -f 1 | tr -cd '[[:alnum:]]' | tr '[:upper:]' '[:lower:]')
USERSURNAME1STLETTER=$(echo ${USERNAMESURNAME} | cut -d " " -f 2 | tr -cd '[[:alnum:]]' | tr '[:upper:]' '[:lower:]' | head -c 1 )
USERLOGINPROP="$USERSURNAME1STLETTER$USERNAMEPROP"
while [[ $USERLOGIN == '' ]]
do
  read -p "Enter user login [$USERLOGINPROP]: " USERLOGIN
  USERLOGIN=${USERLOGIN:-$USERLOGINPROP}
  LOGINNBENTRIES=$(cat $USERSDBDIR/*.yml 2>&1 | grep "userlogin" | grep "^.*\"${USERLOGIN}\".*$" | wc -l)
  if (( $LOGINNBENTRIES > 0 )); then
    echo "User login \"${USERLOGIN}\" already taken, please enter a new one."
    echo ""
    unset USERLOGIN
  fi
done

# ask for sudo permission
unset USERSUDOPERM
while [[ $USERSUDOPERM != 'yes' ]] && [[ $USERSUDOPERM != 'no' ]]
do
  read -p "Will the user have sudo permission ? [yes]: " USERSUDOPERM
  USERSUDOPERM=${USERSUDOPERM:-yes}
done

# ask for user GROUP
unset USERGROUP
read -p "Enter user group [$USERLOGIN]: " USERGROUP
USERGROUP=${USERGROUP:-$USERLOGIN}

# ask for user UID
unset USERUID
read -p "Enter user UID [$USER_NEXT_UID]: " USERUID
USERUID=${USERUID:-$USER_NEXT_UID}

# ask for user GID
unset USERGID
read -p "Enter user GID [$USER_NEXT_UID]: " USERGID
USERGID=${USERGID:-$USER_NEXT_UID}

# ask for SSH key type
unset SSHKEYTYPE
while [[ $SSHKEYTYPE != 'dsa' ]] && [[ $SSHKEYTYPE != 'ecdsa' ]] && [[ $SSHKEYTYPE != 'ed25519' ]] && [[ $SSHKEYTYPE != 'rsa' ]]
do
  read -p "Enter SSH key type (dns/ecdsa/ed25519/rsa) [rsa]: " SSHKEYTYPE
  SSHKEYTYPE=${SSHKEYTYPE:-rsa}
done

# ask for SSH key bits
unset SSHKEYBITS
while [[ $SSHKEYBITS != '1024' ]] && [[ $SSHKEYBITS != '2048' ]] && [[ $SSHKEYBITS != '4096' ]] && [[ $SSHKEYBITS != '256' ]] && [[ $SSHKEYBITS != '384' ]] && [[ $SSHKEYBITS != '521' ]]
do
  read -p "Enter SSH key bits (1024/2048/4096/256/384/521) [4096]: " SSHKEYBITS
  SSHKEYBITS=${SSHKEYBITS:-4096}
done


USERKEYFILEPATH="${USERKEYSDIR}/${NORMALISED_USERNAME}_${DATEHOUR}"
USERKEYFILEPATH=$(echo $USERKEYFILEPATH | tr -s '/')

echo ""
echo "Please verify information here under :"
echo "  NAME Surname            : $USERNAMESURNAME"
echo "  Company                 : $USERCOMPANY"
echo "  Login                   : $USERLOGIN"
echo "  Sudo permission         : $USERSUDOPERM"
echo "  User group              : $USERGROUP"
echo "  USER UID                : $USERUID"
echo "  User GID                : $USERGID"
echo "  ---"
echo "  User SSH keys directory : $USERKEYSDIR"
echo "  SSH key type            : $SSHKEYTYPE"
echo "  SSH key bits            : $SSHKEYBITS"
echo "  User SSH public key     : $USERKEYFILEPATH.pub"
echo "  User SSH private key    : $USERKEYFILEPATH"


# ask for validation
unset INFOCORRECT
while [[ $INFOCORRECT != 'yes' ]] && [[ $INFOCORRECT != 'no' ]]; do
  read -p "Are this information correct ? [yes/no]: " INFOCORRECT
done
if [ $INFOCORRECT == "no" ]; then
  echo "Information set not correct, aborting." 1>&2
  exit 2
fi

if [[ ! -e $USERKEYSDIR ]]; then
  mkdir --parents $USERKEYSDIR
elif [[ ! -d $USERKEYSDIR ]]; then
  echo "$USERKEYSDIR already exists but is not a directory" 1>&2
  exit 3
fi


COMMENT="${USERCOMPANY} :: ${USERNAMESURNAME}"
if [ $USERSUDOPERM == "yes" ]; then
  COMMENT="$COMMENT (sudoer)"
fi

echo ""
echo "Please enter a passphrase when prompted, in order to protect the SSH private key."
echo ""
ssh-keygen -b $SSHKEYBITS -t $SSHKEYTYPE -C "$COMMENT" -f $USERKEYFILEPATH
RESULT=$?

if [ $RESULT == "0" ]; then
  USER_NEXT_UID=$(((${USER_NEXT_UID}+1)))
  echo ${USER_NEXT_UID} > ${USER_NEXT_UID_FILEPATH}
fi

echo ""
echo "New user database file in ${USERDBFILEPATH}:"
echo "${NORMALISED_USERNAME}: " | tee $USERDBFILEPATH
echo "  usernamesurname: \"${USERNAMESURNAME}\"" | tee --append $USERDBFILEPATH
echo "  company: \"${USERCOMPANY}\"" | tee --append $USERDBFILEPATH
echo "  userlogin: \"${USERLOGIN}\"" | tee --append $USERDBFILEPATH
echo "  sudoer: \"${USERSUDOPERM}\"" | tee --append $USERDBFILEPATH
echo "  group: \"${USERGROUP}\"" | tee --append $USERDBFILEPATH
echo "  gid: \"${USERGID}\"" | tee --append $USERDBFILEPATH
echo "  uid: \"${USERUID}\"" | tee --append $USERDBFILEPATH
echo "  ssh_key_type: \"${SSHKEYTYPE}\"" | tee --append $USERDBFILEPATH
echo "  ssh_key_bits: \"${SSHKEYBITS}\"" | tee --append $USERDBFILEPATH
echo "  ssh_key_public_filepath: \"${USERKEYFILEPATH}.pub\"" | tee --append $USERDBFILEPATH
echo "  ssh_key_private_filepath: \"${USERKEYFILEPATH}\"" | tee --append $USERDBFILEPATH
echo "  last_configuration_date: \"${DATEHOUR}\"" | tee --append $USERDBFILEPATH

ansible-playbook ./ansible_add_user.yml --inventory=${AINVENTORYALL}
