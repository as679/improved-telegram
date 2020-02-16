#!/usr/bin/env python3
import argparse
import json
import redis

class inventory(object):
    def __init__(self):
        self.redis = redis.StrictRedis(host='localhost', port=6379, db=0, decode_responses=True)
        self.inventory = {'_meta': {'hostvars': {}}}
        self.redis_instances()

    def redis_instances(self):
        names = self.redis.smembers('names')
        for name in names:
            identity = self.redis.hgetall(name)
            if identity['Lab_Group'] not in self.inventory:
                self.inventory[identity['Lab_Group']] = {'hosts': [identity['Lab_Name']]}
            else:
                self.inventory[identity['Lab_Group']]['hosts'].append(identity['Lab_Name'])
            self.inventory['_meta']['hostvars'][identity['Lab_Name']] = identity

    def host(self, name):
        return json.dumps(self.inventory['_meta']['hostvars'][name])

    def __call__(self):
        return json.dumps(self.inventory)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action="store_true", default=False)
    parser.add_argument('--host')
    args = parser.parse_args()

    inv = inventory()
    if args.list:
        print(inv())
    elif args.host:
        print(inv.host(args.host))
