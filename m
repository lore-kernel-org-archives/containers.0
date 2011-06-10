From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Introduce Vpid: in /proc/self/status
Date: Fri, 10 Jun 2011 11:46:46 +0200
Message-ID: <20110610094646.29106.62700.stgit@bahia.local>
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
Cc: legoater-GANU6spQydw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Since pid namespaces were introduced, there's a recurring demand: how one
can correlate a pid from a child pid ns with a pid from a parent pid ns ?
The need arises in the LXC community when one wants to send a signal from
the host (aka. init_pid_ns context) to a container process for which one
only knows the pid inside the container.

In the future, this should be achievable thanks to Eric Biederman's setns()
syscall but there's still some work to be done to support pid namespaces:

https://lkml.org/lkml/2011/5/21/162

As stated by Serge Hallyn in:

http://sourceforge.net/mailarchive/message.php?msg_id=27424447

"There is nothing that gives you a 100% guaranteed correct race-free
correspondence right now.  You can look under /proc/<pid>/root/proc/ to
see the pids valid in the container, and you can relate output of
lxc-ps --forest to ps --forest output.  But nothing under /proc that I
know of tells you "this task is the same as that task".  You can't
even look at /proc/<pid> inode numbers since they are different
filesystems for each proc mount."

This patch adds a single line to /proc/self/status. Provided one has kept
track of its container tasks (with a cgroup like liblxc does for example),
he may correlate global pids and container pids. This is still racy but
definitely easier than what we have today.

Signed-off-by: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---

 fs/proc/array.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 5e4f776..f9db2a4 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -165,7 +165,8 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 	int g;
 	struct fdtable *fdt = NULL;
 	const struct cred *cred;
-	pid_t ppid, tpid;
+	struct pid_namespace *pid_ns;
+	pid_t ppid, tpid, vpid;
 
 	rcu_read_lock();
 	ppid = pid_alive(p) ?
@@ -176,6 +177,8 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		if (tracer)
 			tpid = task_pid_nr_ns(tracer, ns);
 	}
+	pid_ns = task_active_pid_ns(p);
+	vpid = pid_ns ? task_pid_nr_ns(p, pid_ns) : 0;
 	cred = get_task_cred(p);
 	seq_printf(m,
 		"State:\t%s\n"
@@ -183,12 +186,13 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		"Pid:\t%d\n"
 		"PPid:\t%d\n"
 		"TracerPid:\t%d\n"
+		"VPid:\t%d\n"
 		"Uid:\t%d\t%d\t%d\t%d\n"
 		"Gid:\t%d\t%d\t%d\t%d\n",
 		get_task_state(p),
 		task_tgid_nr_ns(p, ns),
 		pid_nr_ns(pid, ns),
-		ppid, tpid,
+		ppid, tpid, vpid,
 		cred->uid, cred->euid, cred->suid, cred->fsuid,
 		cred->gid, cred->egid, cred->sgid, cred->fsgid);
