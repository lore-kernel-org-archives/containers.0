From: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Subject: [PATCH 15/20] Make proc_flush_task() actually from entries from
 multiple namespaces
Date: Tue, 07 Aug 2007 13:30:04 +0400
Message-ID: <46B83B9C.mailG5T11MYSS@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

This means that proc_flush_task_mnt() is to be called for many proc
mounts and with different ids, depending on the namespace this pid
is to be flushed from.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

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
