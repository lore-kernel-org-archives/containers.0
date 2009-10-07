From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: INET demo script
Date: Wed, 07 Oct 2009 09:25:37 -0700
Message-ID: <87my43f9xa.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

Below is a proposed test script for demonstrating INET socket
migration.  It does the following:

  1. Sets up a virtual interface and plumbs it to an existing bridge,
     both on checkpoint and restart
  2. On checkpoint:
    a. Starts an instance of sendmail
    b. Checkpoints it on request to an image file
    c. Kills off the sendmail instance
  3. On restart:
    a. Pre-freezes traffic to the shared IP
    b. Restarts the image
    c. Un-freezes traffic

With this and the patch I'm about to post, I can migrate a sendmail
instance with live connections between two machines.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

#!/bin/bash
#
# Example script to demonstrate sendmail migration
#
# Copyright 2009 IBM Corp.
# Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
#
# This script can be run in checkpoint or restart mode
#
# In checkpoint, we set up a veth pair, attach one side to $BRIDGE
# and give the other side $CONTAINER_IP.  Then we start sendmail (must
# be configured to listen on 0.0.0.0 or $CONTAINER_IP), wait for the
# user to signal, and then checkpoint sendmail.  After the checkpoint,
# we kill it off, tear down the veth and quit.
#
# On restart, we set up the veth pair again, filter traffic to $CONTAINER_IP,
# restart from the image, and then release the traffic filter.
#
# NOTE THE FOLLOWING BEFORE RUNNING:
#
# 1. This script *deletes* your /dev/log node
# 2. This script munges your iptables tables
# 3. You must have a bridge to your local network, specified by $BRIDGE
# 4. You must put a valid local network address in $CONTAINER_IP
# 5. You must have cgroup mounted with -ofreezer on $FREEZER

CONTAINER_IP=192.168.100.50
CONTAINER_IF=veth1
BRIDGE=br0
FREEZER=/freezer
GROUP=test

setup_vnet() {
    local local_if=veth0

    ip link add $local_if type veth peer name $CONTAINER_IF

    ip addr add $CONTAINER_IP dev $CONTAINER_IF
    brctl addif $BRIDGE $local_if
}

teardown_vnet() {
    ip link del $CONTAINER_IF
}

clamp_vnet() {
    iptables -I INPUT -s $CONTAINER_IP -j DROP
    iptables -I INPUT -d $CONTAINER_IP -j DROP
}

release_vnet() {
    iptables -D INPUT 1
    iptables -D INPUT 1
}

kill_all()
{
    local path="$FREEZER/$GROUP"

    for i in $(cat $path/tasks); do
	kill $i
    done
}

freeze() {
    local path="$FREEZER/$GROUP"

    echo FROZEN > $path/freezer.state
}

thaw() {
    local path="$FREEZER/$GROUP"

    echo THAWED > $path/freezer.state
}

make_freezer() {
    local path="$FREEZER/$GROUP"
    if [ -d $path ]; then
	kill_all
	thaw
	sleep 1
    else
	mkdir $path
    fi
}

add_to_freezer() {
    local pid=$1
    local path="$FREEZER/$GROUP"

    echo $pid > $path/tasks
}

task() {
    rm -f /dev/log # Don't let sendmail talk to syslog
    sendmail -bD >/dev/null 2>&1 &
    pid=$!
    add_to_freezer $pid
    echo $pid
}

do_checkpoint() {
    local pid=$1
    local image=$2

    checkpoint $pid > $image
}

do_restart() {
    local image=$1

    restart < $image
}

send_side() {
    local image=$1

    setup_vnet
    make_freezer
    pid=$(task)
    echo -n "Press enter to checkpoint..."
    read
    freeze
    do_checkpoint $pid $image || echo "Checkpoint FAILED"
    teardown_vnet
    kill_all
    thaw
    echo "Done, all stop"
}

recv_side() {
    local image=$1

    echo foobar99 > /var/run/sendmail.pid

    clamp_vnet
    setup_vnet
    make_freezer
    (do_restart $image || echo "Restart FAILED") &
    echo Waiting for restart...
    sleep 15
    echo Restart complete, freeing network
    release_vnet
}

cleanup() {
    release_vnet
    thaw
    teardown_vnet
    killall sendmail
}

usage() {
    echo "Usage: $1 [c|r|C] image"
}

if [ -z "$2" ]; then
    usage $0
    exit 1;
fi

case "$1" in 
    c)
	cleanup
	send_side $2
	;;
    r)
	cleanup
	recv_side $2
	;;
    C)
	cleanup
	;;
    *)
	usage
	;;
esac
