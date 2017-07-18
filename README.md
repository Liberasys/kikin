KIKIN short description
=======================
KIKIN helps to start quickly with Ansible® (manage hosts adding, SSH keys, user database synchronisation).


Ansible KIKIN
=============
Ansible KIKIN helps to start with Ansible.
It manages user database, ssh keys generation, hosts connections and SSH parameters.
Copyright (C) 2017  Gautier HUSSON, for HUSSON CONSULTING SAS (Liberasys) - FRANCE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


WARNING
=========
This software is given "as this" and you take your own responsibility by using it.
This work is still beta. In order to test safe way :
- backup your ~/.ssh directory
- use new username in user "database" that you will create with this tool
- verify UIDs are not already used (default is to begin at UID 2000)
- test it on test VMs, it is (at now) NOT READY FOR PRODUCTION


HOWTO INSTALL AND CONFIGURE LAST ANSIBLE REVISION
=================================================
```bash
sudo -s
apt-get update
apt-get install python-pip python-dev git -y
pip install PyYAML jinja2 paramiko
cd /opt
git clone https://github.com/ansible/ansible.git
cd ansible
git submodule update --init --recursive
make install
mkdir /etc/ansible
cp ~/ansible/examples/hosts /etc/ansible/.

cat << 'EOF' > ~/.ansible.cfg
[defaults]
log_path = ~/ansible/log/ansible.log
timeout = 1
ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host}
error_on_undefined_vars = True

[ssh_connection]
pipelining = True

[accelerate]
accelerate_port = 5099
accelerate_timeout = 30
accelerate_connect_timeout = 1.0
accelerate_multi_key = yes
EOF
```

HOWTO UPDATE ANSIBLE AFTER THAT
===============================
```bash
sudo -s
cd /opt
git pull https://github.com/ansible/ansible.git
make install
```

REMARKS
=======
SSH authorised key is unique for each user (if you use ansible KIKIN user database with SSH keys, current overlapping users authorised_keys will be overwritten). Understand : unique at managed servers user profiles level.
SSH known_hosts file in your profile (your profile, as current user on a computer/server) will be overriden by ansible KIKIN. Thus, add manually yours hosts keys by using ssh-keysan and putting them in known_hosts__modifyme. Or preferably, use KIKIN to add a host :-)


USING KIKIN
===========
0. download KIKIN : http://github.com/Liberasys/kikin/archive/master.zip or use ```git clone git://github.com/Liberasys/kikin.git```
1. Give a name to your current Ansible instance : ```ansible-playbook ./ansible_name_instance.yml --inventory=/dev/null```
2. Add a user : ```./ansible_add_user.bash```
3. Add a link to a new host (you will be prompted) : ``` ./ansible_link_host.bash ```
4. repeat at 2. or 3. :-)

**If you are ready for an Ansible power demo :**
- run this :
```bash
    ssh-agent /bin/bash
    ssh-add user_present/<user name _ user surname>/<file without .pub>
    # enter your key protection passphrase
    # press Ctrl + D
```
- try to connect to a server you have linked : ```ssh <linked hostname>```
- have a look at file : roles/staging/tasks/main.yml
- run : ```ansible-playbook demo.yml --inventory=./inventory/all.inventory```

**you have now staged all your servers with one command line !!!**

Notes :
=======
- Remove a link to a host (you will be prompted) : ```ansible-playbook ./ansible_unlink_one_host.yml --inventory=/dev/null```
- Remove a user :
  - move the corresponding var file from user_present dir to user_absent dir (and delete or move corresponding subdir)
  - run the users_configured role on all hosts
  - script this ? :-)
- In order to do a whole test (including hosts staging role demo) , run : ansible-playbook configure_all.yml --inventory=./inventory/all.inventory


For restarting to zero with KIKIN or quit it :-( :
===================================================
```bash
# in you Ansible KIKIN directory :
rm roles/local_ssh_configured/vars/main.yml
rm -rf host_vars/ inventory/ local_ssh_config/ user_* *.retry
# in your ~/.ssh directory :
cd ~/.ssh/
rm -rf known_hosts.d/ config.d/
mv known_hosts__modifyme known_hosts
mv config__modifyme config
rm 000__warning_ssh_config_managed_by_ansible__
cd -
```

TODO
====================
- massive debug of all user cases
- test ansible link with localhost
- add password managed by ansible-vault (currently manual passwords are not stored)
- remove and disable user functionnality
- manage group of users and attribute SUDO permissions from users groups to hosts groups
