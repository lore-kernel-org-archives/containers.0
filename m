From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 3/4] proc: Introduce the Children: line in /proc/<pid>/status
Date: Mon, 8 Aug 2011 01:20:31 +0400
Message-ID: <20110807212031.GG2080@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akp>
Cc: Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Cyrill Gorcunov <gorcunov@openvz.org>
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>

Although we can get the pids of some task's issue, this is just 
more convenient to have them this way.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/proc/array.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: linux-2.6.git/fs/proc/array.c
===================================================================
--- linux-2.6.git.orig/fs/proc/array.c
+++ linux-2.6.git/fs/proc/array.c
@@ -158,6 +158,18 @@ static inline const char *get_task_state
 	return *p;
 }
 
+static void task_children(struct seq_file *m, struct task_struct *p, struct pid_namespace *ns)
+{
+	struct task_struct *c;
+
+	seq_printf(m, "Children:");
+	read_lock(&tasklist_lock);
+	list_for_each_entry(c, &p->children, sibling)
+		seq_printf(m, " %d", pid_nr_ns(task_pid(c), ns));
+	read_unlock(&tasklist_lock);
+	seq_putc(m, '\n');
+}
+
 static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *p)
 {
@@ -192,6 +204,8 @@ static inline void task_state(struct seq
 		cred->uid, cred->euid, cred->suid, cred->fsuid,
 		cred->gid, cred->egid, cred->sgid, cred->fsgid);
 
+	task_children(m, p, ns);
+
 	task_lock(p);
 	if (p->files)
 		fdt = files_fdtable(p->files);
