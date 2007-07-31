From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 14/15] Destroy pid namespace on init's death
Date: Mon, 30 Jul 2007 23:19:17 -0700
Message-ID: <20070731061917.GB17013@us.ibm.com>
References: <46A8B37B.6050108@openvz.org> <46A8B663.9040206@openvz.org>
	<20070729104145.GC120@tv-sign.ru> <46ADD202.9030502@openvz.org>
	<20070730154639.GA127@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070730154639.GA127-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| On 07/30, Pavel Emelyanov wrote:
| >
| > Oleg Nesterov wrote:
| > >>+
| > >>+	nfree = 0;
| > >>+	for (i = 0; i < PIDMAP_ENTRIES; i++)
| > >>+		nfree += atomic_read(&pid_ns->pidmap[i].nr_free);
| > >>+
| > >>+	/*
| > >>+	 * If pidmap has entries for processes other than 0 and 1, retry.
| > >>+	 */
| > >>+	if (nfree < (BITS_PER_PAGE * PIDMAP_ENTRIES - 2))
| > >>+		goto repeat;
| > >
| > >This doesn't look right.
| > >
| > >Suppose that some "struct pid" was pinned from the parent namespace.
| > >In that case zap_pid_ns_processes() will burn CPU until put_pid(), bad.
| > 
| > Nope. struct pid can be pinned, but the pidmap "fingerprint" cannot.
| 
| Heh. It was specially designed this way, but I managed to forget.
| 
| You are right, thanks for correcting me.
| 
| > So as soon as the release_task() is called the pidmap becomes free and
| > we can proceed.
| 
| Well, it doesn't matter, but strictly speaking this is not true.
| release_task()->detach_pid(PIDTYPE_PID) doesn't necessary free pidmap,
| it could be "used" by other tasks as PGID/SID.
| 
| > However I agree with the "burn CPU" issue - wait must sleep if needed.
| > 
| > >I think we can rely on forget_original_child() and do something like
| > >this:
| > >
| > >	zap_active_ns_processes(void)
| > >	{
| > >		// kill all tasks in our ns and below
| > >		kill(-1, SIGKILL);
| > 
| > That would be too slow to walk through all the tasks in a node searching
| > for a couple of them we need. fing_ge_pid() looks better to me.
| 
| OK. I personally dislike the "retry" logic (and it is not safe if we want
| wait() to actually sleep waiting for the child), but we can do the "kill"
| loop under tasklist_lock.
| 
| In any case, I don't think we should use next_pid() for wait(), or check
| pidmap[].nr_free,
| 
| > >		do {
| > >			clear_thread_flag(TIF_SIGPENDING);
| > >		} while (wait(NULL) != -ECHLD);
| > >	}
| 
| just wait for any child until -ECHLD. After that we can return safely.

Agree. Here is the modified patch. Hope this is better.


From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/15] Destroy pid namespace on init's death

From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Terminate all processes in a namespace when the reaper of the namespace
is exiting. We do this by walking the pidmap of the namespace and sending
SIGKILL to all processes.

Changelog:
	[Oleg Nesterov]: In zap_pid_ns_processes() wait for any child
		rather than iterating over all pid_ts in the pidmap.

	[Oleg Nesterov]: Must clear the TIF_SIGPENDING flag for
		successive wait() calls.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

 include/linux/pid.h  |    1 +
 include/linux/wait.h |    4 ++++
 kernel/exit.c        |   10 ++++++----
 kernel/pid.c         |   26 ++++++++++++++++++++++++++
 4 files changed, 37 insertions(+), 4 deletions(-)

Index: lx26-23-rc1-mm1/include/linux/pid.h
===================================================================
--- lx26-23-rc1-mm1.orig/include/linux/pid.h	2007-07-26 20:08:16.000000000 -0700
+++ lx26-23-rc1-mm1/include/linux/pid.h	2007-07-26 20:08:16.000000000 -0700
@@ -118,6 +118,7 @@ extern struct pid *find_ge_pid(int nr, s
 
 extern struct pid *alloc_pid(struct pid_namespace *ns);
 extern void FASTCALL(free_pid(struct pid *pid));
+extern void zap_pid_ns_processes(struct pid_namespace *pid_ns);
 
 /*
  * the helpers to get the pid's id seen from different namespaces
Index: lx26-23-rc1-mm1/include/linux/wait.h
===================================================================
--- lx26-23-rc1-mm1.orig/include/linux/wait.h	2007-07-22 13:41:00.000000000 -0700
+++ lx26-23-rc1-mm1/include/linux/wait.h	2007-07-26 20:08:16.000000000 -0700
@@ -22,9 +22,13 @@
 #include <linux/list.h>
 #include <linux/stddef.h>
 #include <linux/spinlock.h>
+#include <linux/resource.h>
+#include <asm/siginfo.h>
 #include <asm/system.h>
 #include <asm/current.h>
 
+long do_wait(pid_t pid, int options, struct siginfo __user *infop,
+		int __user *stat_addr, struct rusage __user *ru);
 typedef struct __wait_queue wait_queue_t;
 typedef int (*wait_queue_func_t)(wait_queue_t *wait, unsigned mode, int sync, void *key);
 int default_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
Index: lx26-23-rc1-mm1/kernel/exit.c
===================================================================
--- lx26-23-rc1-mm1.orig/kernel/exit.c	2007-07-26 20:08:16.000000000 -0700
+++ lx26-23-rc1-mm1/kernel/exit.c	2007-07-30 23:10:30.000000000 -0700
@@ -915,6 +915,7 @@ fastcall NORET_TYPE void do_exit(long co
 {
 	struct task_struct *tsk = current;
 	int group_dead;
+	struct pid_namespace *pid_ns = tsk->nsproxy->pid_ns;
 
 	profile_task_exit(tsk);
 
@@ -925,9 +926,10 @@ fastcall NORET_TYPE void do_exit(long co
 	if (unlikely(!tsk->pid))
 		panic("Attempted to kill the idle task!");
 	if (unlikely(tsk == task_child_reaper(tsk))) {
-		if (task_active_pid_ns(tsk) != &init_pid_ns)
-			task_active_pid_ns(tsk)->child_reaper =
-					init_pid_ns.child_reaper;
+		if (pid_ns != &init_pid_ns) {
+			zap_pid_ns_processes(pid_ns);
+			pid_ns->child_reaper = init_pid_ns.child_reaper;
+		}
 		else
 			panic("Attempted to kill init!");
 	}
@@ -1537,7 +1539,7 @@ static inline int my_ptrace_child(struct
 	return (p->parent != p->real_parent);
 }
 
-static long do_wait(pid_t pid, int options, struct siginfo __user *infop,
+long do_wait(pid_t pid, int options, struct siginfo __user *infop,
 		    int __user *stat_addr, struct rusage __user *ru)
 {
 	DECLARE_WAITQUEUE(wait, current);
Index: lx26-23-rc1-mm1/kernel/pid.c
===================================================================
--- lx26-23-rc1-mm1.orig/kernel/pid.c	2007-07-26 20:08:16.000000000 -0700
+++ lx26-23-rc1-mm1/kernel/pid.c	2007-07-30 23:12:33.000000000 -0700
@@ -593,6 +593,32 @@ out:
 	return new_ns;
 }
 
+void zap_pid_ns_processes(struct pid_namespace *pid_ns)
+{
+	int nr;
+	int rc;
+	int options = WEXITED|__WALL;
+
+	/*
+	 * We know pid == 1 is terminating. Find remaining pid_ts
+	 * in the namespace, signal them and then wait for them
+	 * exit.
+	 */
+	nr = next_pidmap(pid_ns, 1);
+	while (nr > 0) {
+		kill_proc_info(SIGKILL, SEND_SIG_PRIV, nr);
+		nr = next_pidmap(pid_ns, nr);
+	}
+
+	do {
+		clear_thread_flag(TIF_SIGPENDING);
+		rc = do_wait(-1, options, NULL, NULL, NULL);
+	} while (rc != -ECHILD);
+
+
+	return;
+}
+
 static void do_free_pid_ns(struct work_struct *w)
 {
 	struct pid_namespace *ns, *parent;
