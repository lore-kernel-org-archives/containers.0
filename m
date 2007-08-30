From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/3] Masquerade sender and limit system-wide signals
Date: Wed, 29 Aug 2007 23:22:10 -0700
Message-ID: <20070830062210.GC29340@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH] Masquerade sender if in ancestor ns

If sender of a signal does not have a pid_t in the active pid namespace
of the caller (eg if sender is in an ancestor namespace), pretend that
the signal originated from the kernel.

Also, system-wide signals (kill -s sig -1) should only apply to the
active namespace of the sender and its descendant namespaces.
Specifically it should not affect processes in ancestor or unrelated
namespaces.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/signal.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

Index: 2.6.23-rc3-mm1/kernel/signal.c
===================================================================
--- 2.6.23-rc3-mm1.orig/kernel/signal.c	2007-08-29 17:38:01.000000000 -0700
+++ 2.6.23-rc3-mm1/kernel/signal.c	2007-08-29 17:38:01.000000000 -0700
@@ -691,6 +691,19 @@ static void handle_stop_signal(int sig, 
 	}
 }
 
+static void masquerade_sender(struct task_struct *t, struct sigqueue *q)
+{
+	/*
+	 * If the sender does not have a pid_t in the receiver's active
+	 * pid namespace, set si_pid to 0 and pretend signal originated
+	 * from the kernel.
+	 */
+	if (!pid_ns_equal(t)) {
+		q->info.si_pid = 0;
+		q->info.si_code = SI_KERNEL;
+	}
+}
+
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			struct sigpending *signals)
 {
@@ -742,6 +755,7 @@ static int send_signal(int sig, struct s
 			copy_siginfo(&q->info, info);
 			break;
 		}
+		masquerade_sender(t, q);
 	} else if (!is_si_special(info)) {
 		if (sig >= SIGRTMIN && info->si_code != SI_USER)
 		/*
@@ -1175,6 +1189,7 @@ EXPORT_SYMBOL_GPL(kill_pid_info_as_uid);
 static int kill_something_info(int sig, struct siginfo *info, int pid)
 {
 	int ret;
+
 	rcu_read_lock();
 	if (!pid) {
 		ret = kill_pgrp_info(sig, info, task_pgrp(current));
@@ -1184,6 +1199,12 @@ static int kill_something_info(int sig, 
 
 		read_lock(&tasklist_lock);
 		for_each_process(p) {
+			/*
+			 * System-wide signals only apply to pid namespace
+			 * of sender.
+			 */
+			if (!task_descendant_pid_ns(p, current))
+				continue;
 			if (p->pid > 1 && !same_thread_group(p, current)) {
 				int err = group_send_sig_info(sig, info, p);
 				++count;
