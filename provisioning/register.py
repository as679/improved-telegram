#!/usr/bin/env python3
import requests
import datetime
import json
import sys
import redis
import os
def touch(fname):
    with open(fname, 'a'):
        os.utime(fname, None)
def get_url(url):
    response = requests.get(url)
    try:
        response.raise_for_status()
    except:
        return None
    try:
        return response.json()
    except ValueError:
        return response.text
blocker_fname = "/opt/register_blocker"
exists = os.path.isfile(blocker_fname)
if not exists:
    redis_host = sys.argv[1]
    identity = get_url('http://169.254.169.254/latest/dynamic/instance-identity/document')
    identity['public-ipv4'] = get_url('http://169.254.169.254/latest/meta-data/public-ipv4')
    identity['awslocalhostname'] = get_url('http://169.254.169.254/latest/meta-data/local-hostname')
    identity['now'] = datetime.datetime.now().isoformat()
    identity['localhostname'] = os.uname()[1]
    report = { identity['instanceId']: identity }
    r = redis.client.StrictRedis(host=redis_host, port=6379, db=0)
    r.publish('instances', json.dumps(report))
    touch(blocker_fname)