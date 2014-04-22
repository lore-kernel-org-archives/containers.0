From: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] ns: Introduce pid_in_ns under /proc
Date: Tue, 22 Apr 2014 18:03:08 +0800
Message-ID: <1398160988-21577-1-git-send-email-chenhanxiao__21832.7384129681$1398161925$gmane$org@cn.fujitsu.com>
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
List-Id: containers.vger.kernel.org

We lacked of convenient method of getting the pid inside containers.
If some issues occurred inside container guest, host user
could not know which process is in trouble just by guest pid:
the users of container guest only knew the pid inside containers.
This will bring obstacle for trouble shooting.

This patch introduces pid_in_ns:
If one process is in init_pid_ns, /proc/PID/pid_in_ns
equals to /proc/PID;
if one process is in pidns, /proc/PID/pid_in_ns
will tell the pid inside containers;
if pidns is nested, it depends on which pidns are you in.

Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/proc/array.c    | 13 +++++++++++++
 fs/proc/base.c     |  1 +
 fs/proc/internal.h |  2 ++
 3 files changed, 16 insertions(+)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 64db2bc..8c3014b 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -562,6 +562,19 @@ int proc_tgid_stat(struct seq_file *m, struct pid_namespace *ns,
 	return do_task_stat(m, ns, pid, task, 1);
 }
 
+int proc_pid_in_ns(struct seq_file *m, struct pid_namespace *ns,
+			struct pid *pid, struct task_struct *task)
+{
+        pid_t pid_in_ns;
+        int level;
+
+        level = pid->level;
+        pid_in_ns = task_pid_nr_ns(task, pid->numbers[level].ns);
+        seq_put_decimal_ull(m, 0, pid_in_ns);
+        seq_putc(m, '\n');
+        return 0;
+}
+
 int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 2d696b0..42904b7 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2574,6 +2574,7 @@ static const struct pid_entry tgid_base_stuff[] = {
 	INF("cmdline",    S_IRUGO, proc_pid_cmdline),
 	ONE("stat",       S_IRUGO, proc_tgid_stat),
 	ONE("statm",      S_IRUGO, proc_pid_statm),
+	ONE("pid_in_ns",  S_IRUGO, proc_pid_in_ns),
 	REG("maps",       S_IRUGO, proc_pid_maps_operations),
 #ifdef CONFIG_NUMA
 	REG("numa_maps",  S_IRUGO, proc_pid_numa_maps_operations),
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 3ab6d14..573841a 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -155,6 +155,8 @@ extern int proc_pid_status(struct seq_file *, struct pid_namespace *,
 			   struct pid *, struct task_struct *);
 extern int proc_pid_statm(struct seq_file *, struct pid_namespace *,
 			  struct pid *, struct task_struct *);
+extern int proc_pid_in_ns(struct seq_file *, struct pid_namespace *,
+			  struct pid *, struct task_struct *);
 
 /*
  * base.c
-- 
1.9.0
