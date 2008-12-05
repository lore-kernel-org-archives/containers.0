From: Nadia.Derbey@bull.net
Subject: [RFC][PATCH 1/1] Fix si_pid value when notifying about message arrival on POSIX mqueue
Date: Fri, 05 Dec 2008 07:50:54 +0100
Message-ID: <20081205065210.495580470@bull.net>
References: <20081205065053.966672287@bull.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755141AbYLEGyQ@vger.kernel.org>
Content-Disposition: inline; filename=mq_notify_fix_si_pid.patch
Sender: linux-kernel-owner@vger.kernel.org
To: containers@lists.osdl.org, oleg@redhat.com, xemul@openvz.org, sukadev@us.ibm.com
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org, Nadia.Derbey@bull.net
List-Id: containers.vger.kernel.org


If a process registers for asynchronous notification on a POSIX message
queue, it gets a signal and a siginfo_t structure when a message arrives on
the message queue. The si_pid in the siginfo_t structure is set to the PID of 
the process that sent the message to the message queue.

The principle is the following:
. when mq_notify(SIGEV_SIGNAL) is called, the caller registers for
  notification when a msg arrives. The associated pid structure is stroed into
  inode_info->notify_owner. Let's call this process P1.
. when mq_send() is called by say P2, P2 sends a signal to P1 to notify
  him about msg arrival.

The way .si_pid is set today is not correct, since it doesn't take into account
the fact that the process that is sending the message might not be in the
same namespace as the notified one.

This patch proposes to set si_pid to the sender's pid into the notify_owner
namespace.

Note: I've integrated in this patch a patch sent by Suka last week, that
      defines ns_of_pid() (see http://lkml.org/lkml/2008/11/25/460)

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>
---
 include/linux/pid.h |   11 +++++++++++
 ipc/mqueue.c        |   12 +++++++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

Index: linux-2.6.28-rc7/ipc/mqueue.c
===================================================================
--- linux-2.6.28-rc7.orig/ipc/mqueue.c	2008-12-04 14:22:15.000000000 +0100
+++ linux-2.6.28-rc7/ipc/mqueue.c	2008-12-04 17:19:41.000000000 +0100
@@ -31,6 +31,7 @@
 #include <linux/mutex.h>
 #include <linux/nsproxy.h>
 #include <linux/pid.h>
+#include <linux/pid_namespace.h>
 
 #include <net/sock.h>
 #include "util.h"
@@ -502,15 +503,24 @@ static void __do_notify(struct mqueue_in
 		case SIGEV_SIGNAL:
 			/* sends signal */
 
+			{
+			struct pid_namespace *notify_ns;
+
 			sig_i.si_signo = info->notify.sigev_signo;
 			sig_i.si_errno = 0;
 			sig_i.si_code = SI_MESGQ;
 			sig_i.si_value = info->notify.sigev_value;
-			sig_i.si_pid = task_tgid_vnr(current);
+
+			rcu_read_lock();
+			notify_ns = ns_of_pid(info->notify_owner);
+			sig_i.si_pid = task_tgid_nr_ns(current, notify_ns);
+			rcu_read_unlock();
+
 			sig_i.si_uid = current->uid;
 
 			kill_pid_info(info->notify.sigev_signo,
 				      &sig_i, info->notify_owner);
+			}
 			break;
 		case SIGEV_THREAD:
 			set_cookie(info->notify_cookie, NOTIFY_WOKENUP);
Index: linux-2.6.28-rc7/include/linux/pid.h
===================================================================
--- linux-2.6.28-rc7.orig/include/linux/pid.h	2008-12-04 14:21:21.000000000 +0100
+++ linux-2.6.28-rc7/include/linux/pid.h	2008-12-04 14:57:56.000000000 +0100
@@ -122,6 +122,17 @@ int next_pidmap(struct pid_namespace *pi
 extern struct pid *alloc_pid(struct pid_namespace *ns);
 extern void free_pid(struct pid *pid);
 
+/* ns_of_pid returns the pid namespace in which the specified
+ * pid was allocated.
+ */
+static inline struct pid_namespace *ns_of_pid(struct pid *pid)
+{
+	struct pid_namespace *ns = NULL;
+	if (pid)
+		ns = pid->numbers[pid->level].ns;
+	return ns;
+}
+
 /*
  * the helpers to get the pid's id seen from different namespaces
  *

-- 
