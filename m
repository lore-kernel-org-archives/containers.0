From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 13/13] userns: Remove the now unnecessary
	FS_USERNS_DEV_MOUNT flag
Date: Mon, 20 Jun 2016 12:21:30 -0500
Message-ID: <20160620172130.15712-13-ebiederm@xmission.com>
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

Now that SB_I_NODEV controls the nodev behavior devpts can just clear
this flag during mount.  Simplifying the code and making it easier
to audit how the code works.  While still preserving the invariant
that s_iflags is only modified during mount.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/devpts/inode.c  | 3 ++-
 fs/super.c         | 3 +--
 include/linux/fs.h | 1 -
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 37c134a132c7..d116453b0276 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -396,6 +396,7 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 {
 	struct inode *inode;
 
+	s->s_iflags &= ~SB_I_NODEV;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
 	s->s_magic = DEVPTS_SUPER_MAGIC;
@@ -480,7 +481,7 @@ static struct file_system_type devpts_fs_type = {
 	.name		= "devpts",
 	.mount		= devpts_mount,
 	.kill_sb	= devpts_kill_sb,
-	.fs_flags	= FS_USERNS_MOUNT | FS_USERNS_DEV_MOUNT,
+	.fs_flags	= FS_USERNS_MOUNT,
 };
 
 /*
diff --git a/fs/super.c b/fs/super.c
index 25cdceed2ad3..37813bf479cf 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -206,8 +206,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	init_waitqueue_head(&s->s_writers.wait_unfrozen);
 	s->s_bdi = &noop_backing_dev_info;
 	s->s_flags = flags;
-	if ((s->s_user_ns != &init_user_ns) &&
-	    !(type->fs_flags & FS_USERNS_DEV_MOUNT))
+	if (s->s_user_ns != &init_user_ns)
 		s->s_iflags |= SB_I_NODEV;
 	INIT_HLIST_NODE(&s->s_instances);
 	INIT_HLIST_BL_HEAD(&s->s_anon);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e05983170d23..375e37f42cdf 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2022,7 +2022,6 @@ struct file_system_type {
 #define FS_BINARY_MOUNTDATA	2
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
-#define FS_USERNS_DEV_MOUNT	16 /* A userns mount does not imply MNT_NODEV */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
-- 
2.8.3
