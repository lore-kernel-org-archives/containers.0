From: Greg Kurz <gkurz@fr.ibm.com>
Subject: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was Vpid:)
Date: Wed, 15 Jun 2011 16:55:27 +0200
Message-ID: <20110615145527.4016.70157.stgit@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, ebiederm@xmission.com, oleg@redhat.com, xemul@openvz.org
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

ChangeLog:
	v2: - changed Vpid: to ActivePid:
	    - lock ->sighand before calling task_active_pid_ns()

Signed-off-by: Greg Kurz <gkurz@fr.ibm.com>
Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
---

 fs/proc/array.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 5e4f776..5f796d9 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -165,7 +165,8 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 	int g;
 	struct fdtable *fdt = NULL;
 	const struct cred *cred;
-	pid_t ppid, tpid;
+	pid_t ppid, tpid, actpid;
+	struct sighand_struct *sighand;
 
 	rcu_read_lock();
 	ppid = pid_alive(p) ?
@@ -176,6 +177,17 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		if (tracer)
 			tpid = task_pid_nr_ns(tracer, ns);
 	}
+	actpid = 0;
+	sighand = rcu_dereference(p->sighand);
+	if (sighand) {
+		struct pid_namespace *pid_ns;
+		unsigned long flags;
+		spin_lock_irqsave(&sighand->siglock, flags);
+		pid_ns = task_active_pid_ns(p);
+		if (pid_ns)
+			actpid = task_pid_nr_ns(p, pid_ns);
+		spin_unlock_irqrestore(&sighand->siglock, flags);
+	}
 	cred = get_task_cred(p);
 	seq_printf(m,
 		"State:\t%s\n"
@@ -183,12 +195,13 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		"Pid:\t%d\n"
 		"PPid:\t%d\n"
 		"TracerPid:\t%d\n"
+		"ActivePid:\t%d\n"
 		"Uid:\t%d\t%d\t%d\t%d\n"
 		"Gid:\t%d\t%d\t%d\t%d\n",
 		get_task_state(p),
 		task_tgid_nr_ns(p, ns),
 		pid_nr_ns(pid, ns),
-		ppid, tpid,
+		ppid, tpid, actpid,
 		cred->uid, cred->euid, cred->suid, cred->fsuid,
 		cred->gid, cred->egid, cred->sgid, cred->fsgid);
 
