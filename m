From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 05/13] proc: Convert proc_mount to use mount_ns.
Date: Mon, 20 Jun 2016 12:21:22 -0500
Message-ID: <20160620172130.15712-5-ebiederm@xmission.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
	<20160620172130.15712-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160620172130.15712-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Move the call of get_pid_ns, the call of proc_parse_options, and
the setting of s_iflags into proc_fill_super so that mount_ns
can be used.

Convert proc_mount to call mount_ns and remove the now unnecessary
code.

Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/inode.c    |  9 +++++++--
 fs/proc/internal.h |  3 ++-
 fs/proc/root.c     | 52 ++++------------------------------------------------
 3 files changed, 13 insertions(+), 51 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 78fa452d65ed..f4817efb25a6 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -457,12 +457,17 @@ struct inode *proc_get_inode(struct super_block *sb, struct proc_dir_entry *de)
 	return inode;
 }
 
-int proc_fill_super(struct super_block *s)
+int proc_fill_super(struct super_block *s, void *data, int silent)
 {
+	struct pid_namespace *ns = get_pid_ns(s->s_fs_info);
 	struct inode *root_inode;
 	int ret;
 
-	s->s_iflags |= SB_I_USERNS_VISIBLE;
+	if (!proc_parse_options(data, ns))
+		return -EINVAL;
+
+	/* User space would break if executables appear on proc */
+	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC;
 	s->s_flags |= MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index aa2781095bd1..7931c558c192 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -212,7 +212,7 @@ extern const struct inode_operations proc_pid_link_inode_operations;
 
 extern void proc_init_inodecache(void);
 extern struct inode *proc_get_inode(struct super_block *, struct proc_dir_entry *);
-extern int proc_fill_super(struct super_block *);
+extern int proc_fill_super(struct super_block *, void *data, int flags);
 extern void proc_entry_rundown(struct proc_dir_entry *);
 
 /*
@@ -268,6 +268,7 @@ static inline void proc_tty_init(void) {}
  * root.c
  */
 extern struct proc_dir_entry proc_root;
+extern int proc_parse_options(char *options, struct pid_namespace *pid);
 
 extern void proc_self_init(void);
 extern int proc_remount(struct super_block *, int *, char *);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index a1b2860fec62..8d3e484055a6 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -23,21 +23,6 @@
 
 #include "internal.h"
 
-static int proc_test_super(struct super_block *sb, void *data)
-{
-	return sb->s_fs_info == data;
-}
-
-static int proc_set_super(struct super_block *sb, void *data)
-{
-	int err = set_anon_super(sb, NULL);
-	if (!err) {
-		struct pid_namespace *ns = (struct pid_namespace *)data;
-		sb->s_fs_info = get_pid_ns(ns);
-	}
-	return err;
-}
-
 enum {
 	Opt_gid, Opt_hidepid, Opt_err,
 };
@@ -48,7 +33,7 @@ static const match_table_t tokens = {
 	{Opt_err, NULL},
 };
 
-static int proc_parse_options(char *options, struct pid_namespace *pid)
+int proc_parse_options(char *options, struct pid_namespace *pid)
 {
 	char *p;
 	substring_t args[MAX_OPT_ARGS];
@@ -100,45 +85,16 @@ int proc_remount(struct super_block *sb, int *flags, char *data)
 static struct dentry *proc_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
-	int err;
-	struct super_block *sb;
 	struct pid_namespace *ns;
-	char *options;
 
 	if (flags & MS_KERNMOUNT) {
-		ns = (struct pid_namespace *)data;
-		options = NULL;
+		ns = data;
+		data = NULL;
 	} else {
 		ns = task_active_pid_ns(current);
-		options = data;
-
-		/* Does the mounter have privilege over the pid namespace? */
-		if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
-			return ERR_PTR(-EPERM);
-	}
-
-	sb = sget(fs_type, proc_test_super, proc_set_super, flags, ns);
-	if (IS_ERR(sb))
-		return ERR_CAST(sb);
-
-	if (!proc_parse_options(options, ns)) {
-		deactivate_locked_super(sb);
-		return ERR_PTR(-EINVAL);
-	}
-
-	if (!sb->s_root) {
-		err = proc_fill_super(sb);
-		if (err) {
-			deactivate_locked_super(sb);
-			return ERR_PTR(err);
-		}
-
-		sb->s_flags |= MS_ACTIVE;
-		/* User space would break if executables appear on proc */
-		sb->s_iflags |= SB_I_NOEXEC;
 	}
 
-	return dget(sb->s_root);
+	return mount_ns(fs_type, flags, data, ns, ns->user_ns, proc_fill_super);
 }
 
 static void proc_kill_sb(struct super_block *sb)
-- 
2.8.3
