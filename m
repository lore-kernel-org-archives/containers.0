From: "Michael J. Coss" <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
Subject: [PATCH 0/3] kobject: support namespace aware udev
Date: Wed,  9 Sep 2015 14:53:10 -0400
Message-ID: <cover.1441762578.git.michael.coss__38124.075838323$1441824846$gmane$org@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
Cc: "Michael J. Coss" <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Currently when a uevent occurs, the event is replicated and sent to every
listener on the kernel netlink socket, ignoring network namespaces boundaries,
forwarding events to every listener in every network namespace.

With the expanded use of containers, it would be useful to be able to
regulate this flow of events to specific containers.  By restricting
the events to only the host network namespace, it allows for a userspace
program to provide a system wide policy on which events are routed where.

A new kernel function (kobject_uevent_forward) was added which allows
forwarding a given message to any uevent listeners in the network namespace
of the specified pid and a generic netlink module was added to provide an
interface to that kernel function.  This allows a userspace program to be
able to read the uevents via the libudev, and apply a policy (drop, forward,
or modify), and sending those uevents to a specific network namespace, and
by association to a specific container.

By allowing a controlled flow of uevents to a container, it is possible
for the container to run udevd, processing the event as normal while
allowing the host to maintain control over what events are sent.

Michael J. Coss (3):
  lib/kobject_uevent.c: disable broadcast of uevents to other namespaces
  lib/kobject_uevent.c: add uevent forwarding function
  net/udevns: Netlink module to forward uevent to containers

 include/linux/kobject.h     |   3 ++
 include/net/net_namespace.h |   3 ++
 include/uapi/linux/Kbuild   |   1 +
 include/uapi/linux/udevns.h |  19 ++++++++
 kernel/ksysfs.c             |  12 +++++
 lib/kobject_uevent.c        |  94 +++++++++++++++++++++++++++++++++++++
 net/Kconfig                 |   1 +
 net/Makefile                |   1 +
 net/udevns/Kconfig          |   9 ++++
 net/udevns/Makefile         |   5 ++
 net/udevns/udevns.c         | 112 ++++++++++++++++++++++++++++++++++++++++++++
 net/udevns/udevns.h         |  19 ++++++++
 12 files changed, 279 insertions(+)
 create mode 100644 include/uapi/linux/udevns.h
 create mode 100644 net/udevns/Kconfig
 create mode 100644 net/udevns/Makefile
 create mode 100644 net/udevns/udevns.c
 create mode 100644 net/udevns/udevns.h

-- 
2.4.6
