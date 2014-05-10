From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V2 4/6] namespaces: expose ns instance serial numbers in proc
Date: Fri,  9 May 2014 20:27:25 -0400
Message-ID: <466cbb2ecbc3afdb31e1166123e94add668dcb20.1399681022.git.rgb__48072.3417284482$1399681733$gmane$org@redhat.com>
References: <cover.1399681022.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Expose the namespace instace serial numbers in the proc filesystem at
/proc/<pid>/ns/<ns>_snum.  The link text gives the serial number in hex.

"snum" was chosen instead of "seq" for consistency with inum and there are a
number of other uses of "seq" in the namespace code.

Suggested-by: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

---
Although it works as expected, I'm not that happy with this patch because it
duplicates a lot of code, including minor changes to proc_ns_follow_link(),
proc_ns_readlink(), ns_dname() that will be harder to keep consistent.  The
only way I could see to get that information into those functions would be
through dentry.  Maybe the information needed is already in there in d_name or
d_iname?  Or I could add a flag to d_flags (there are 9 bits unused?) but that
flag isn't useful for any other types of entries, so I'm not so keen to pollute
it.
---
 fs/proc/namespaces.c |  150 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 138 insertions(+), 12 deletions(-)

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 9ae46b8..40bab47 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -42,6 +42,11 @@ static const struct inode_operations ns_inode_operations = {
 	.setattr	= proc_setattr,
 };
 
+enum ns_num {
+	PROC_NS_INUM,
+	PROC_NS_SNUM
+};
+
 static char *ns_dname(struct dentry *dentry, char *buffer, int buflen)
 {
 	struct inode *inode = dentry->d_inode;
@@ -51,14 +56,28 @@ static char *ns_dname(struct dentry *dentry, char *buffer, int buflen)
 		ns_ops->name, inode->i_ino);
 }
 
-const struct dentry_operations ns_dentry_operations =
-{
+const struct dentry_operations ns_dentry_operations = {
 	.d_delete	= always_delete_dentry,
 	.d_dname	= ns_dname,
 };
 
+static char *ns_snum_dname(struct dentry *dentry, char *buffer, int buflen)
+{
+	struct inode *inode = dentry->d_inode;
+	const struct proc_ns_operations *ns_ops = PROC_I(inode)->ns.ns_ops;
+
+	return dynamic_dname(dentry, buffer, buflen, "%s_snum:[%llx]",
+		ns_ops->name, ns_ops->snum(PROC_I(inode)->ns.ns));
+}
+
+const struct dentry_operations ns_snum_dentry_operations = {
+	.d_delete	= always_delete_dentry,
+	.d_dname	= ns_snum_dname,
+};
+
 static struct dentry *proc_ns_get_dentry(struct super_block *sb,
-	struct task_struct *task, const struct proc_ns_operations *ns_ops)
+	struct task_struct *task, const struct proc_ns_operations *ns_ops,
+	enum ns_num ns_num)
 {
 	struct dentry *dentry, *result;
 	struct inode *inode;
@@ -96,7 +115,10 @@ static struct dentry *proc_ns_get_dentry(struct super_block *sb,
 		ns_ops->put(ns);
 	}
 
-	d_set_d_op(dentry, &ns_dentry_operations);
+	if (ns_num == PROC_NS_INUM)
+		d_set_d_op(dentry, &ns_dentry_operations);
+	else if (ns_num == PROC_NS_SNUM)
+		d_set_d_op(dentry, &ns_snum_dentry_operations);
 	result = d_instantiate_unique(dentry, inode);
 	if (result) {
 		dput(dentry);
@@ -122,7 +144,39 @@ static void *proc_ns_follow_link(struct dentry *dentry, struct nameidata *nd)
 	if (!ptrace_may_access(task, PTRACE_MODE_READ))
 		goto out_put_task;
 
-	ns_path.dentry = proc_ns_get_dentry(sb, task, ei->ns.ns_ops);
+	ns_path.dentry = proc_ns_get_dentry(sb, task, ei->ns.ns_ops, PROC_NS_INUM);
+	if (IS_ERR(ns_path.dentry)) {
+		error = ERR_CAST(ns_path.dentry);
+		goto out_put_task;
+	}
+
+	ns_path.mnt = mntget(nd->path.mnt);
+	nd_jump_link(nd, &ns_path);
+	error = NULL;
+
+out_put_task:
+	put_task_struct(task);
+out:
+	return error;
+}
+
+static void *proc_ns_snum_follow_link(struct dentry *dentry, struct nameidata *nd)
+{
+	struct inode *inode = dentry->d_inode;
+	struct super_block *sb = inode->i_sb;
+	struct proc_inode *ei = PROC_I(inode);
+	struct task_struct *task;
+	struct path ns_path;
+	void *error = ERR_PTR(-EACCES);
+
+	task = get_proc_task(inode);
+	if (!task)
+		goto out;
+
+	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+		goto out_put_task;
+
+	ns_path.dentry = proc_ns_get_dentry(sb, task, ei->ns.ns_ops, PROC_NS_SNUM);
 	if (IS_ERR(ns_path.dentry)) {
 		error = ERR_CAST(ns_path.dentry);
 		goto out_put_task;
@@ -181,10 +235,59 @@ static const struct inode_operations proc_ns_link_inode_operations = {
 	.setattr	= proc_setattr,
 };
 
+static int proc_ns_snum_readlink(struct dentry *dentry, char __user *buffer, int buflen)
+{
+	struct inode *inode = dentry->d_inode;
+	struct proc_inode *ei = PROC_I(inode);
+	const struct proc_ns_operations *ns_ops = ei->ns.ns_ops;
+	struct task_struct *task;
+	void *ns;
+	char name[50];
+	int len = -EACCES;
+
+	task = get_proc_task(inode);
+	if (!task)
+		goto out;
+
+	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+		goto out_put_task;
+
+	len = -ENOENT;
+	ns = ns_ops->get(task);
+	if (!ns)
+		goto out_put_task;
+
+	snprintf(name, sizeof(name), "%s_snum:[%llx]", ns_ops->name, ns_ops->snum(ns));
+	len = strlen(name);
+
+	if (len > buflen)
+		len = buflen;
+	if (copy_to_user(buffer, name, len))
+		len = -EFAULT;
+
+	ns_ops->put(ns);
+out_put_task:
+	put_task_struct(task);
+out:
+	return len;
+}
+
+static const struct inode_operations proc_ns_snum_link_inode_operations = {
+	.readlink	= proc_ns_snum_readlink,
+	.follow_link	= proc_ns_snum_follow_link,
+	.setattr	= proc_setattr,
+};
+
+struct proc_ns_entry {
+	const struct proc_ns_operations *ns_ops;
+	enum ns_num ns_num;
+};
+
 static int proc_ns_instantiate(struct inode *dir,
 	struct dentry *dentry, struct task_struct *task, const void *ptr)
 {
-	const struct proc_ns_operations *ns_ops = ptr;
+	const struct proc_ns_entry *ns_entry = ptr;
+	const struct proc_ns_operations *ns_ops = ns_entry->ns_ops;
 	struct inode *inode;
 	struct proc_inode *ei;
 
@@ -194,7 +297,10 @@ static int proc_ns_instantiate(struct inode *dir,
 
 	ei = PROC_I(inode);
 	inode->i_mode = S_IFLNK|S_IRWXUGO;
-	inode->i_op = &proc_ns_link_inode_operations;
+	if (ns_entry->ns_num == PROC_NS_INUM)
+		inode->i_op = &proc_ns_link_inode_operations;
+	else if (ns_entry->ns_num == PROC_NS_SNUM)
+		inode->i_op = &proc_ns_snum_link_inode_operations;
 	ei->ns.ns_ops = ns_ops;
 
 	d_set_d_op(dentry, &pid_dentry_operations);
@@ -216,14 +322,23 @@ static int proc_ns_dir_readdir(struct file *file, struct dir_context *ctx)
 
 	if (!dir_emit_dots(file, ctx))
 		goto out;
-	if (ctx->pos >= 2 + ARRAY_SIZE(ns_entries))
+	if (ctx->pos >= 2 + 2 * ARRAY_SIZE(ns_entries))
 		goto out;
 	entry = ns_entries + (ctx->pos - 2);
 	last = &ns_entries[ARRAY_SIZE(ns_entries) - 1];
 	while (entry <= last) {
 		const struct proc_ns_operations *ops = *entry;
+		char name[50];
+		struct proc_ns_entry ns_entry = { ops, PROC_NS_INUM };
+
 		if (!proc_fill_cache(file, ctx, ops->name, strlen(ops->name),
-				     proc_ns_instantiate, task, ops))
+				     proc_ns_instantiate, task, &ns_entry))
+			break;
+		ctx->pos++;
+		ns_entry.ns_num = PROC_NS_SNUM;
+		snprintf(name, sizeof(name), "%s_snum", ops->name);
+		if (!proc_fill_cache(file, ctx, name, strlen(name),
+				     proc_ns_instantiate, task, &ns_entry))
 			break;
 		ctx->pos++;
 		entry++;
@@ -245,6 +360,7 @@ static struct dentry *proc_ns_dir_lookup(struct inode *dir,
 	struct task_struct *task = get_proc_task(dir);
 	const struct proc_ns_operations **entry, **last;
 	unsigned int len = dentry->d_name.len;
+	struct proc_ns_entry ns_entry;
 
 	error = -ENOENT;
 
@@ -253,15 +369,25 @@ static struct dentry *proc_ns_dir_lookup(struct inode *dir,
 
 	last = &ns_entries[ARRAY_SIZE(ns_entries)];
 	for (entry = ns_entries; entry < last; entry++) {
-		if (strlen((*entry)->name) != len)
+		char name[50];
+
+		snprintf(name, sizeof(name), "%s_snum", (*entry)->name);
+		if (strlen((*entry)->name) != len && strlen(name) != len)
 			continue;
-		if (!memcmp(dentry->d_name.name, (*entry)->name, len))
+		if (!memcmp(dentry->d_name.name, (*entry)->name, len)) {
+			ns_entry.ns_ops = *entry;
+			ns_entry.ns_num = PROC_NS_INUM;
+			break;
+		} else if (!memcmp(dentry->d_name.name, name, len)) {
+			ns_entry.ns_ops = *entry;
+			ns_entry.ns_num = PROC_NS_SNUM;
 			break;
+		}
 	}
 	if (entry == last)
 		goto out;
 
-	error = proc_ns_instantiate(dir, dentry, task, *entry);
+	error = proc_ns_instantiate(dir, dentry, task, &ns_entry);
 out:
 	put_task_struct(task);
 out_no_task:
-- 
1.7.1
