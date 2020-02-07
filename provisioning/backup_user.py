#!/usr/bin/env python
import requests
import socket
import urllib3
import getopt, sys
urllib3.disable_warnings()


class AviNewUser(object):
  def __init__(self, host=None, new_user=None, new_passwd=None, user='admin', passwd='58NFaGDJm(PJH0G', is_superuser=True):
    self.name = new_user
    self.password = new_passwd
    self.is_superuser = is_superuser
    self.access = []
    session = requests.Session()
    session.post("https://%s/login" % socket.gethostbyname(host), verify=False, json={'username': user, 'password': passwd}).raise_for_status()
    self._add_user(socket.gethostbyname(host), session)
  def _add_user(self, ip, session):
    session.headers.update({'Referer': "https://%s/" % ip})
    session.headers.update({'X-CSRFToken': session.cookies['csrftoken']})
    session.post("https://%s/api/user" % ip, json=self.__dict__).raise_for_status()

if __name__ == '__main__':
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:u:p:")
    except getopt.GetoptError as err:
        print str(err)  # will print something like "option -a not recognized"
        #usage()
        sys.exit(2)
    for o, a in opts:
        if o == "-h":
            host = a
        elif o == "-u":
            user = a
        elif o == "-p":
            password= a
        else:
            assert False, "unhandled option"

    AviNewUser(host, user, password)
