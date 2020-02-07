#!/bin/bash -e

systemctl daemon-reload
systemctl enable redis
systemctl start redis
systemctl enable squid
systemctl start squid
systemctl enable nginx
systemctl start nginx
pip install --upgrade ansible==2.6.12
pip install --upgrade avisdk 
ansible-galaxy install avinetworks.avisdk avinetworks.aviconfig --force
git clone git://github.com/ansible/ansible-runner /tmp/ansible-runner
pip install /tmp/ansible-runner/
chmod +x /usr/local/bin/handle_bootstrap.py
chmod +x /usr/local/bin/handle_register.py
chmod +x /usr/local/bin/cleanup_controllers.py
systemctl enable handle_bootstrap
systemctl enable handle_register
systemctl start handle_bootstrap
systemctl start handle_register
chmod +x /etc/ansible/hosts
cp /usr/local/bin/register.py /usr/share/nginx/html/
cp /etc/ansible/hosts /opt/bootstrap/inventory
#Nasty, nasty, very very nasty...
sleep 5
/usr/local/bin/register.py localhost
