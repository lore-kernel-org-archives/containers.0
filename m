From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH V1 12/12] debug! audit: add container id
Date: Thu,  1 Mar 2018 14:41:15 -0500
Message-ID: <c6da3e0fe8cdd173cf9d5cd090229d3f215bc590.1519930146.git.rgb__49951.641917187$1519933578$gmane$org@redhat.com>
References: <cover.1519930146.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1519930146.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1519930146.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1519930146.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, madzcar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
List-Id: containers.vger.kernel.org

Debugging code for verbose output to aid in development.
---
 fs/proc/base.c   | 10 ++++++++++
 kernel/auditsc.c | 16 ++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index f66d1e2..63d1ca4 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1309,9 +1309,13 @@ static ssize_t proc_containerid_read(struct file *file, char __user *buf,
 	char tmpbuf[TMPBUFLEN*2];
 
 	if (!task)
+	{
+		pr_info("no inode owner");
 		return -ESRCH;
+	}
 	length = scnprintf(tmpbuf, TMPBUFLEN*2, "%llu", audit_get_containerid(task));
 	put_task_struct(task);
+	pr_info("read: pid=%d opid=%d contid=%llu", pid_nr(task_tgid(current)), pid_nr(task_tgid(task)), audit_get_containerid(task));
 	return simple_read_from_buffer(buf, count, ppos, tmpbuf, length);
 }
 
@@ -1324,14 +1328,19 @@ static ssize_t proc_containerid_write(struct file *file, const char __user *buf,
 	struct task_struct *task = get_proc_task(inode);
 
 	if (!task)
+	{
+		pr_info("no inode owner");
 		return -ESRCH;
+	}
 	if (*ppos != 0) {
 		/* No partial writes. */
 		put_task_struct(task);
+		pr_info("no partial writes");
 		return -EINVAL;
 	}
 
 	rv = kstrtou64_from_user(buf, count, 10, &containerid);
+	pr_info("write: pid=%d rv=%d count=%ld opid=%d contid=%llu", task_tgid_nr(current), rv, count, task_tgid_nr(task), containerid);
 	if (rv < 0) {
 		put_task_struct(task);
 		return rv;
@@ -1339,6 +1348,7 @@ static ssize_t proc_containerid_write(struct file *file, const char __user *buf,
 
 	rv = audit_set_containerid(task, containerid);
 	put_task_struct(task);
+	//pr_info("audit_set_containerid: rv=%d", rv);
 	if (rv < 0)
 		return rv;
 	return count;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index fcee34e..39e7dc10 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -2111,16 +2111,28 @@ static int audit_set_containerid_perm(struct task_struct *task, u64 containerid)
 
 	/* Don't allow to set our own containerid */
 	if (current == task)
+	{
+		pr_info("pid=%d can't set own containerid", task_tgid_nr(task));
 		return -EPERM;
+	}
 	/* Don't allow the containerid to be unset */
 	if (!cid_valid(containerid))
+	{
+		pr_info("can't unset containerid");
 		return -EINVAL;
+	}
 	/* if we don't have caps, reject */
 	if (!capable(CAP_AUDIT_CONTROL))
+	{
+		pr_info("don't have CAP_AUDIT_CONTROL");
 		return -EPERM;
+	}
 	/* if containerid is unset, allow */
 	if (!audit_containerid_set(task))
+	{
+		//pr_info("unset, allow");
 		return 0;
+	}
 	/* it is already set, and not inherited from the parent, reject */
 	ccontainerid = audit_get_containerid(task);
 	rcu_read_lock();
@@ -2131,7 +2143,11 @@ static int audit_set_containerid_perm(struct task_struct *task, u64 containerid)
 	ppid = task_tgid_nr(parent);
 	task_unlock(parent);
 	if (ccontainerid != pcontainerid)
+	{
+		pr_info("pid=%d already has contid=%llu set, not inherited from ppid=%d with contid=%llu, can't set containerid %llu",
+			task_tgid_nr(task), ccontainerid, ppid, pcontainerid, containerid);
 		return -EPERM;
+	}
 	return 0;
 }
 
-- 
1.8.3.1
