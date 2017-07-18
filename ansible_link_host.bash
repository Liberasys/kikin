#!/bin/bash
# Copyright : Liberasys (HUSSON CONSULTING SAS) - 201702 - Gautier HUSSON

# TODO : user input validation

AINVENTORYALL="inventory/all.inventory"
SSHCONFIG=$(mktemp --suffix=.ansible_sshconfig)
AINVENTORY=$(mktemp --suffix=.ansible_inventory)
AHOSTSVARSDIR="host_vars/"

echo "Ansible KIKIN"
echo "Copyright (C) 2017  Gautier HUSSON, for HUSSON CONSULTING SAS (Liberasys)"
echo "This program comes with ABSOLUTELY NO WARRANTY; for details,"
echo "read README.txt file."
echo "    This is free software, and you are welcome to redistribute it"
echo "    under certain conditions; read license.txt file for details."
echo ""


###############################################################################
# Host parameters
###############################################################################
# ask for hostname
unset AHOST
while [[ $AHOST == '' ]]
do
    read -p "Enter hostname (fqdn): " AHOST
done

# ask for a ansible host group
unset AGROUP
while [[ $AGROUP == '' ]]
do
    read -p "Enter Ansible host group [all]: " AGROUP
    AGROUP=${AGROUP:-all}
done

if [[ AHOST != "localhost" ]]; then
  # ask for forced IP
  unset AFORCEDIP
  read -p "Enter forced IP/host (or nothing if you don't want to): " AFORCEDIP

  # ask for SSH port
  unset APORT
  read -p "Enter SSH connection port [22]: " APORT
  APORT=${APORT:-22}
else
  AFORCEDIP=""
  APORT="22"
fi

###############################################################################
# Initial connection parameters
###############################################################################

# ask for initial connection user name
unset AUSER
read -p "Enter initial connection username [root]: " AUSER
AUSER=${AUSER:-root}

# ask for initial connection sudo need
unset ASUDO
while [[ $ASUDO != 'yes' ]] && [[ $ASUDO != 'no' ]]
do
    read -p "Will sudo be needed for this initial connection ? [no]: " ASUDO
    ASUDO=${ASUDO:-no}
done

if [[ $ASUDO == "yes" ]]; then
  # ask for initial connection sudo password need
  unset ASUDOPASSNEEDED
  while [[ $ASUDOPASSNEEDED != 'yes' ]] && [[ $ASUDOPASSNEEDED != 'no' ]]
  do
    read -p "Will sudo password be needed for this initial connection? [no]: " ASUDOPASSNEEDED
    ASUDOPASSNEEDED=${ASUDOPASSNEEDED:-no}
  done
else
  ASUDOPASSNEEDED="no"
fi

###############################################################################
# Next connections forced credentials parameters
###############################################################################

# ask for forced user credentials to connect to host (on next connection)
unset FORCEDUSERCRED
while [[ $FORCEDUSERCRED != 'yes' ]] && [[ $FORCEDUSERCRED != 'no' ]]
do
  read -p "Will the next connections need some forced user credentials? [no]: " FORCEDUSERCRED
  FORCEDUSERCRED=${FORCEDUSERCRED:-no}
done

if [[ $FORCEDUSERCRED == 'yes' ]]; then
  # ask for the next connections forced username
  unset ANEXTCONUSERNAME
  while [[ $ANEXTCONUSERNAME == '' ]]
  do
    read -p "Enter final forced username [root]: " ANEXTCONUSERNAME
    ANEXTCONUSERNAME=${ANEXTCONUSERNAME:-root}
  done
else
  ANEXTCONUSERNAME=""
fi

if [[ $FORCEDUSERCRED == 'yes' ]]; then
  # ask for the for the next connections sudo need
  unset ANEXTCONSUDO
  while [[ $ANEXTCONSUDO != 'yes' ]] && [[ $ANEXTCONSUDO != 'no' ]]
  do
      read -p "Will sudo be needed for the next connections? [no]: " ANEXTCONSUDO
      ANEXTCONSUDO=${ANEXTCONSUDO:-no}
  done
else
  ANEXTCONSUDO="no"
fi

if [[ $FORCEDUSERCRED == 'yes' ]] && [[ $ANEXTCONSUDO == 'yes' ]]; then
  # ask for the next connections sudo password need
  unset ANEXTCONSUDOPASSNEEDED
  while [[ $ANEXTCONSUDOPASSNEEDED != 'yes' ]] && [[ $ANEXTCONSUDOPASSNEEDED != 'no' ]]
  do
    read -p "Will sudo password be needed for the next connections? [no]: " ANEXTCONSUDOPASSNEEDED
    ANEXTCONSUDOPASSNEEDED=${ANEXTCONSUDOPASSNEEDED:-no}
  done
else
  ANEXTCONSUDOPASSNEEDED="no"
fi

if [[ $FORCEDUSERCRED == 'yes' ]] && [[ $ANEXTCONSUDO == 'yes' ]] && [[ $ANEXTCONSUDOPASSNEEDED == "yes" ]]; then
  # ask for the next connections sudo password
  unset ANEXTCONSUDOPASS
  while [[ $ANEXTCONSUDOPASS == "" ]]
  do
    read -p "Enter next connections sudo password: " ANEXTCONSUDOPASS
    ANEXTCONSUDOPASS=${ANEXTCONSUDOPASS:-}
  done
else
  ANEXTCONSUDOPASS=""
fi

###############################################################################
# users/groups/sudoers synchronisation
###############################################################################

# ask for users/groups/sudoers synchronisation with host
unset UGSDBSYNC
while [[ $UGSDBSYNC != 'yes' ]] && [[ $UGSDBSYNC != 'no' ]]
do
    read -p "Do you want that users/groups/sudoers database to be synchronised with host? [yes]: " UGSDBSYNC
    UGSDBSYNC=${UGSDBSYNC:-yes}
done

###############################################################################
# Summary and human verification
###############################################################################

echo ""
echo "Please verify information here under :"
echo "  (permanent configuration):"
echo "    Host FQDN         : $AHOST"
echo "    Ansible group     : $AGROUP"
echo "    Forced IP/host    : $AFORCEDIP"
echo "    SSH port          : $APORT"
echo "  (only for this initial connection):"
echo "    SSH username      : $AUSER"
echo "    SSH sudo          : $ASUDO"
echo "  (for next connections :)"
echo "    SSH username      : ${ANEXTCONUSERNAME:-}"
echo "    SSH sudo          : ${ANEXTCONSUDO:-}"
echo "    SSH sudo password : ${ANEXTCONSUDOPASS:-}"
echo "  Users/groups/sudoers sync : ${UGSDBSYNC:-}"

# ask for validation
unset INFOCORRECT
while [[ $INFOCORRECT != 'yes' ]] && [[ $INFOCORRECT != 'no' ]]
do
    read -p "Are this information correct ? [yes/no]: " INFOCORRECT
done

if [[ $INFOCORRECT == "no" ]]; then
  echo "Information set not correct, aborting." 1>&2
  exit 1
fi

###############################################################################
# Temporary inventory and ssh_config file build
###############################################################################

# build temporary ssh configuration file
echo "Host ${AHOST}" >> $SSHCONFIG
echo "    Hostname ${AFORCEDIP:-${AHOST}}" >> $SSHCONFIG
echo "    Port ${APORT:-22}" >> $SSHCONFIG
echo "    User ${AUSER:-root}" >> $SSHCONFIG
cat $SSHCONFIG

# build temporary Ansible inventory file
echo "localhost ansible_connection=local" >> $AINVENTORY
echo "${AHOST}" >> $AINVENTORY
#cat $AINVENTORY

###############################################################################
# Ansible inventory creation if needed
###############################################################################

# if global Ansible inventory is not present, create it
grep "[all]" ${AINVENTORYALL}  > /dev/null 2>&1
RESULT=$?
if [ $RESULT != 0 ]; then
  if [ ! -e $(dirname ${AINVENTORYALL}) ]; then
     mkdir --parents $(dirname ${AINVENTORYALL})
  fi
  echo "[all]" > ${AINVENTORYALL}
fi

###############################################################################
# Localhost host_vars file creation if needed
###############################################################################

# if localhost hosts_var file does not exists, create it
grep "ansible_connection: local" ${AHOSTSVARSDIR}/localhost  > /dev/null 2>&1
RESULT=$?
if [ $RESULT != 0 ]; then
  if [ ! -e ${AHOSTSVARSDIR} ]; then
     mkdir --parents ${AHOSTSVARSDIR}
  fi
  echo "ansible_connection: local" >> ${AHOSTSVARSDIR}/localhost
fi

###############################################################################
# Ansible playbook arguments build
###############################################################################

# compute ansible-playbook arguments
if [[ $ASUDO == "yes" ]]; then
  ASUDOARG="--sudo"
else
  ASUDOARG=""
fi
if [[ $ASUDOPASSNEEDED == "yes" ]]; then
  ASUDOPASSARG="--ask-become-pass"
else
  ASUDOPASSARG=""
fi

###############################################################################
# Playbook run
###############################################################################

# echo ansible-playbook ansible-playbook -vvv ./ansible_link_host.yml \
# --inventory="${AINVENTORY}" \
# --ask-pass $ASUDOARG $ASUDOPASSARG \
# --extra-vars="ansible_host=${AHOST}" \
# --extra-vars="ansible_forced_ip=${AFORCEDIP}" \
# --extra-vars="ansible_port=${APORT:-22}" \
# --extra-vars="nextcons_ansible_group=${AGROUP}" \
# --extra-vars="ansible_user=${AUSER:-root}" \
# --extra-vars="nextcons_ansible_user=${ANEXTCONUSERNAME}" \
# --extra-vars="nextcons_ansible_become=${ANEXTCONSUDO}" \
# --extra-vars="nextcons_become_pass=${ANEXTCONSUDOPASS}" \
# --extra-vars="tmp_file_sshconfig=${SSHCONFIG}" \
# --extra-vars="tmp_file_ainventory=${AINVENTORY}" \
# --extra-vars="ugs_synchronisation=${UGSDBSYNC}" \
# --extra-vars="ansible_ssh_common_args=\"-F ${SSHCONFIG} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\""

ansible-playbook ./ansible_link_host.yml \
--inventory="${AINVENTORY}" \
--ask-pass $ASUDOARG $ASUDOPASSARG \
--extra-vars="ansible_host=${AHOST}" \
--extra-vars="ansible_forced_ip=${AFORCEDIP}" \
--extra-vars="ansible_port=${APORT:-22}" \
--extra-vars="nextcons_ansible_group=${AGROUP}" \
--extra-vars="ansible_user=${AUSER:-root}" \
--extra-vars="nextcons_ansible_user=${ANEXTCONUSERNAME}" \
--extra-vars="nextcons_ansible_become=${ANEXTCONSUDO}" \
--extra-vars="nextcons_become_pass=${ANEXTCONSUDOPASS}" \
--extra-vars="tmp_file_sshconfig=${SSHCONFIG}" \
--extra-vars="tmp_file_ainventory=${AINVENTORY}" \
--extra-vars="ugs_synchronisation=${UGSDBSYNC}" \
--extra-vars="ansible_ssh_common_args=\"-F ${SSHCONFIG} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\""

ansible-playbook ./generate_local_ssh_config.yml --inventory=$AINVENTORYALL
