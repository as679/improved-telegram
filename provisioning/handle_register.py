#!/usr/bin/env python3
import requests
import boto3
import redis
import json
import psutil
import os
import signal


class identity(object):
    def __init__(self, document=None, url='http://169.254.169.254/latest/dynamic/instance-identity/document'):
        if document is None:
            identity = self._get_url(url)
        else:
            identity = document
        for k, v in identity.items():
            if isinstance(k, str):
                setattr(self, k, v)
            else:
                setattr(self, k.decode('utf-8'), v)

    def _get_url(self, url):
        response = requests.get(url)
        try:
            response.raise_for_status()
        except:
            return None
        try:
            return response.json()
        except ValueError:
            return response.text

    def __call__(self):
        return self.__dict__

class instance_tags(object):
    def __init__(self, document=None):
        if document is None:
            self.identity = identity()
        else:
            self.identity = identity(document=document)
        self.ec2 = boto3.client('ec2', self.identity.region)
        if self.identity.instanceId is not None:
            tags = self.get_tags(self.identity.instanceId)
            for tag in tags:
                setattr(self.identity, tag['Key'], tag['Value'])

    def get_tags(self, instance_id):
        filter = {'Name': 'resource-id', 'Values': []}
        filter['Values'].append(instance_id)
        response = self.ec2.describe_tags(Filters=[filter])
        return response['Tags']


class hosts_file(object):
    def __init__(self, ip_address, hostname, filename='/etc/hosts'):
        hosts = {}
        found = False
        with open(filename) as fh:
            original_hosts = fh.readlines()
        for line in original_hosts:
            try:
                (ip, name) = line.split()
                if hostname == name:
                    hosts[name] = ip_address
                else:
                    hosts[name] = ip
            except ValueError as err:
                pass
        if not found:
            hosts[hostname] = ip_address
        with open(filename, 'w') as fh:
            for k in hosts.keys():
                if isinstance(k, bytes):
                    k = k.decode()
                print('%s\t%s' % (hosts[k], k), file=fh)
        for pid in psutil.process_iter(['pid', 'name']):
            if pid.info['name'] == "dnsmasq":
                os.kill(pid.info['pid'], signal.SIGHUP)
                break


class update_redis(object):
    def __init__(self, redis_session, id):
        self.redis_session = redis_session
        self.identity = id
        self.redis_instances()

    def redis_instances(self):
        old_identity = r.hgetall(self.identity.Name)
        if old_identity:
            self.old_identity = identity(document=old_identity)
            r.srem(self.old_identity.Lab_Group, self.old_identity.privateIp)
        r.hmset(self.identity.Name, self.identity())
        r.sadd(self.identity.Lab_Group, self.identity.privateIp)
        r.sadd('groups', self.identity.Lab_Group)
        r.sadd('names', self.identity.Name)


if __name__ == '__main__':
    r = redis.StrictRedis(host='localhost', port=6379, db=0)
    p = r.pubsub()
    p.subscribe('instances')
    for m in p.listen():
        if m['type'] == 'message':
            data = json.loads(m['data'].decode('utf-8'))
            id = list(data.keys())[0]
            tags = instance_tags(document=data[id])
            hosts_file(tags.identity.privateIp, tags.identity.Lab_Name)
            if data[id]['public-ipv4']:
                hosts_file(data[id]['public-ipv4'], 'public.%s' % tags.identity.Lab_Name)
            update_redis(r, tags.identity)
            r.publish('bootstrap', json.dumps({'bootstrap': tags.identity.Lab_Name}))
