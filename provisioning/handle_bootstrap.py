#!/usr/bin/env python3
import argparse
import redis
import json
import ansible_runner
import threading
import logging
import signal
import sys
from time import sleep

logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

task_list = []
housekeeping_task = None

INTERVAL = 5.0

def signal_handler(signum, frame):
    global task_list
    log.debug('caught interrupt...')
    housekeeping_task.cancel()
    while len(task_list) != 0:
        log.debug('- total tasks: %s' % len(task_list))
        for task in task_list:
            if not task[0].is_alive():
                log.info(task[1].stdout.readlines())
                task_list.remove(task)
        if len(task_list) != 0:
            sleep(INTERVAL)
    sys.exit(0)

def housekeeping():
    log.debug('housekeeping woke up...')
    log.debug('- total tasks: %s' % len(task_list))
    for task in task_list:
        log.debug('- task alive: %s' % task[0].is_alive())
        if not task[0].is_alive():
            log.info(task[1].stdout.readlines())
            task_list.remove(task)
    global housekeeping_task
    housekeeping_task = threading.Timer(INTERVAL, housekeeping)
    housekeeping_task.start()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--project', required=True)
    parser.add_argument('--debug', action='store_true', default=False)
    args = parser.parse_args()

    if args.debug:
        log.setLevel(logging.DEBUG)

    data_dir = '/opt/' + args.project
    playbook = args.project + '.yml'
    log.info('ansible_runner startup, project: %s' % args.project)
    log.info('- data_dir: %s' % data_dir)
    log.info('- playbook: %s' % playbook)

    r = redis.StrictRedis(host='localhost', port=6379, db=0)
    p = r.pubsub()
    p.subscribe('bootstrap')

    signal.signal(signal.SIGINT, signal_handler)
    housekeeping()

    for m in p.listen():
        if m['type'] == 'message':
            log.debug('incoming message...')
            data = json.loads(m['data'])
            hostname = data['bootstrap']
            task_list.append(ansible_runner.run_async(playbook=playbook,
                                                private_data_dir=data_dir,
                                                limit=hostname,
                                                quiet=True))
