From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] userns: Support autofs4 interacing with multiple user
	namespaces
Date: Tue, 30 Oct 2012 23:33:32 -0700
Message-ID: <87y5im819x.fsf@xmission.com>
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
To: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Use kuid_t and kgid_t in struct autofs_info and struct autofs_wait_queue.

When creating directories and symlinks default the uid and gid of
the mount requester to the global root uid and gid.  autofs4_wait
will update these fields when a mount is requested.

When generating autofsv5 packets report the uid and gid of the mount
requestor in user namespace of the process that opened the pipe,
reporting unmapped uids and gids as overflowuid and overflowgid.

In autofs_dev_ioctl_requester return the uid and gid of the last mount
requester converted into the calling processes user namespace.  When the
uid or gid don't map return overflowuid and overflowgid as appropriate,
allowing failure to find a mount requester to be distinguished from
failure to map a mount requester.

The uid and gid mount options specifying the user and group of the
root autofs inode are converted into kuid and kgid as they are parsed
defaulting to the current uid and current gid of the process that
mounts autofs.

Mounting of autofs for the present remains confined to processes in
the initial user namespace.

Cc: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

Resending because my first posting appears to have disappeared into a
black hole.

 fs/autofs4/autofs_i.h  |    8 ++++----
 fs/autofs4/dev-ioctl.c |    4 ++--
 fs/autofs4/inode.c     |   24 +++++++++++++++---------
 fs/autofs4/waitq.c     |    5 +++--
 init/Kconfig           |    1 -
 5 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index 908e184..b785e77 100644
--- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -74,8 +74,8 @@ struct autofs_info {
 	unsigned long last_used;
 	atomic_t count;
 
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 };
 
 #define AUTOFS_INF_EXPIRING	(1<<0) /* dentry is in the process of expiring */
@@ -89,8 +89,8 @@ struct autofs_wait_queue {
 	struct qstr name;
 	u32 dev;
 	u64 ino;
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 	pid_t pid;
 	pid_t tgid;
 	/* This is for status reporting upon return */
diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
index a162141..9f68a37 100644
--- a/fs/autofs4/dev-ioctl.c
+++ b/fs/autofs4/dev-ioctl.c
@@ -437,8 +437,8 @@ static int autofs_dev_ioctl_requester(struct file *fp,
 		err = 0;
 		autofs4_expire_wait(path.dentry);
 		spin_lock(&sbi->fs_lock);
-		param->requester.uid = ino->uid;
-		param->requester.gid = ino->gid;
+		param->requester.uid = from_kuid_munged(current_user_ns(), ino->uid);
+		param->requester.gid = from_kgid_munged(current_user_ns(), ino->gid);
 		spin_unlock(&sbi->fs_lock);
 	}
 	path_put(&path);
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 8a4fed8..b104726 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -36,8 +36,8 @@ struct autofs_info *autofs4_new_ino(struct autofs_sb_info *sbi)
 
 void autofs4_clean_ino(struct autofs_info *ino)
 {
-	ino->uid = 0;
-	ino->gid = 0;
+	ino->uid = GLOBAL_ROOT_UID;
+	ino->gid = GLOBAL_ROOT_GID;
 	ino->last_used = jiffies;
 }
 
@@ -79,10 +79,12 @@ static int autofs4_show_options(struct seq_file *m, struct dentry *root)
 		return 0;
 
 	seq_printf(m, ",fd=%d", sbi->pipefd);
-	if (root_inode->i_uid != 0)
-		seq_printf(m, ",uid=%u", root_inode->i_uid);
-	if (root_inode->i_gid != 0)
-		seq_printf(m, ",gid=%u", root_inode->i_gid);
+	if (!uid_eq(root_inode->i_uid, GLOBAL_ROOT_UID))
+		seq_printf(m, ",uid=%u",
+			from_kuid_munged(&init_user_ns, root_inode->i_uid));
+	if (!gid_eq(root_inode->i_gid, GLOBAL_ROOT_GID))
+		seq_printf(m, ",gid=%u",
+			from_kgid_munged(&init_user_ns, root_inode->i_gid));
 	seq_printf(m, ",pgrp=%d", sbi->oz_pgrp);
 	seq_printf(m, ",timeout=%lu", sbi->exp_timeout/HZ);
 	seq_printf(m, ",minproto=%d", sbi->min_proto);
@@ -126,7 +128,7 @@ static const match_table_t tokens = {
 	{Opt_err, NULL}
 };
 
-static int parse_options(char *options, int *pipefd, uid_t *uid, gid_t *gid,
+static int parse_options(char *options, int *pipefd, kuid_t *uid, kgid_t *gid,
 		pid_t *pgrp, unsigned int *type, int *minproto, int *maxproto)
 {
 	char *p;
@@ -159,12 +161,16 @@ static int parse_options(char *options, int *pipefd, uid_t *uid, gid_t *gid,
 		case Opt_uid:
 			if (match_int(args, &option))
 				return 1;
-			*uid = option;
+			*uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(*uid))
+				return 1;
 			break;
 		case Opt_gid:
 			if (match_int(args, &option))
 				return 1;
-			*gid = option;
+			*gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(*gid))
+				return 1;
 			break;
 		case Opt_pgrp:
 			if (match_int(args, &option))
diff --git a/fs/autofs4/waitq.c b/fs/autofs4/waitq.c
index dce436e..03bc1d3 100644
--- a/fs/autofs4/waitq.c
+++ b/fs/autofs4/waitq.c
@@ -154,6 +154,7 @@ static void autofs4_notify_daemon(struct autofs_sb_info *sbi,
 	case autofs_ptype_expire_direct:
 	{
 		struct autofs_v5_packet *packet = &pkt.v5_pkt.v5_packet;
+		struct user_namespace *user_ns = sbi->pipe->f_cred->user_ns;
 
 		pktsz = sizeof(*packet);
 
@@ -163,8 +164,8 @@ static void autofs4_notify_daemon(struct autofs_sb_info *sbi,
 		packet->name[wq->name.len] = '\0';
 		packet->dev = wq->dev;
 		packet->ino = wq->ino;
-		packet->uid = wq->uid;
-		packet->gid = wq->gid;
+		packet->uid = from_kuid_munged(user_ns, wq->uid);
+		packet->gid = from_kgid_munged(user_ns, wq->gid);
 		packet->pid = wq->pid;
 		packet->tgid = wq->tgid;
 		break;
diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..b6369fb 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1004,7 +1004,6 @@ config UIDGID_CONVERTED
 	# Filesystems
 	depends on 9P_FS = n
 	depends on AFS_FS = n
-	depends on AUTOFS4_FS = n
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-- 
1.7.5.4
