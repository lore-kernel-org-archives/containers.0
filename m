From: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/9] Add namespace support for syslog v2
Date: Mon, 29 Jul 2013 10:31:11 +0800
Message-ID: <1375065080-26740-1-git-send-email-rui.xiang__15469.0019124702$1375065289$gmane$org@huawei.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset introduces a system log namespace.

It is the 2nd version. The link of the 1st version is 
http://lwn.net/Articles/525728/. In that version, syslog_
namespace was added into nsproxy and created through a new
clone flag CLONE_SYSLOG when cloning a process. 

There were some discussion in last November about the 1st 
version. This version used these important advice, and 
referred to Serge's patch(http://lwn.net/Articles/525629/).

Unlike the 1st version, in this patchset, syslog namespace 
is tied to a user namespace. Add we must create a new user 
ns before create a new syslog ns, because that will make 
users have full capabilities in this new userns after 
cloning a new user ns. The syslog namespace can be created 
through a new command(11) to __NR_syslog syscall. That owe 
to a new syslog flag SYSLOG_ACTION_NEW_NS.

In syslog_namespace, some necessary identifiers for handling 
syslog buf are containerized. When one container creates a
new syslog ns, individual buf will be allocated to store log
ownned this container. 

A new interface ns_printk is added to print the logs which 
we want to see in the container. Through ns_printk, we can 
get more logs related to a specific net ns, for instance, 
iptables. Here we use it to report iptable logs per 
contianer.

Then default printk targeted at the init_syslog_ns will 
continue to print out most kernel log to host.

One task in a new syslog ns could affect only current 
container through "dmesg", "dmesg -c" and /dev/kmsg 
actions. The read/write interface such as /dev/kmsg, 
/pro/kmsg and syslog syscall continue to be useful for 
container users.

This patchset is based on linus' linux tree.

Rui Xiang (9):
  syslog_ns: add syslog_namespace and put/get_syslog_ns
  syslog_ns: add syslog_ns into user_namespace
  syslog_ns: add init syslog_ns for global syslog
  syslog_ns: make syslog handling per namespace
  syslog_ns: make permisiion check per user namespace
  syslog_ns: use init syslog_ns for console action
  syslog_ns: implement function for creating syslog ns
  syslog_ns: implement ns_printk for specific syslog_ns
  netfilter: use ns_printk in iptable context

 fs/proc/kmsg.c                 |  17 +-
 include/linux/printk.h         |   5 +-
 include/linux/syslog.h         |  79 ++++-
 include/linux/user_namespace.h |   2 +
 include/net/netfilter/xt_log.h |   6 +-
 kernel/printk.c                | 642 ++++++++++++++++++++++++-----------------
 kernel/sysctl.c                |   3 +-
 kernel/user.c                  |   3 +
 kernel/user_namespace.c        |   4 +
 net/netfilter/xt_LOG.c         |   4 +-
 10 files changed, 493 insertions(+), 272 deletions(-)

-- 
1.8.2.2
