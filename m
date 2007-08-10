From: xemul@openvz.org
Subject: [PATCH 14/20] Make proc_flush_task() actually from entries from
 multiple namespaces
Date: Fri, 10 Aug 2007 15:48:18 +0400
Message-ID: <46BC5082.mailGKP1JQOQQ@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S937654AbXHJL5r@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@osdl.org
Cc: xemul@openvz.org, devel@openvz.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, oleg@tv-sign.ru, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

This means that proc_flush_task_mnt() is to be called for many proc
mounts and with different ids, depending on the namespace this pid
is to be flushed from.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>

---

 base.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

--- ./fs/proc/base.c.ve12	2007-08-06 14:58:51.000000000 +0400
+++ ./fs/proc/base.c	2007-08-06 14:58:51.000000000 +0400
@@ -2170,8 +2170,22 @@ out:
 
 void proc_flush_task(struct task_struct *task)
 {
-	proc_flush_task_mnt(proc_mnt, task->pid,
-			thread_group_leader(task) ? 0 : task->tgid);
+	int i, leader;
+	struct pid *pid, *tgid;
+	struct upid *upid;
+
+	leader = thread_group_leader(task);
+	proc_flush_task_mnt(proc_mnt, task->pid, leader ? task->tgid : 0);
+	pid = task_pid(task);
+	if (pid->level == 0)
+		return;
+
+	tgid = task_tgid(task);
+	for (i = 1; i <= pid->level; i++) {
+		upid = &pid->numbers[i];
+		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
+				leader ? 0 : tgid->numbers[i].nr);
+	}
 }
 
 static struct dentry *proc_pid_instantiate(struct inode *dir,
