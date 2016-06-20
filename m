From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 08/13] kernfs: The cgroup filesystem also benefits from
	SB_I_NOEXEC
Date: Mon, 20 Jun 2016 12:21:25 -0500
Message-ID: <20160620172130.15712-8-ebiederm@xmission.com>
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

The cgroup filesystem is in the same boat as sysfs.  No one ever
permits executables of any kind on the cgroup filesystem, and there is
no reasonable future case to support executables in the future.

Therefore move the setting of SB_I_NOEXEC which makes the code proof
against future mistakes of accidentally creating executables from
sysfs to kernfs itself.  Making the code simpler and covering the
sysfs, cgroup, and cgroup2 filesystems.

Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/kernfs/mount.c | 2 ++
 fs/sysfs/mount.c  | 3 +--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index d90d574c15a2..1443df670260 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -152,6 +152,8 @@ static int kernfs_fill_super(struct super_block *sb, unsigned long magic)
 	struct dentry *root;
 
 	info->sb = sb;
+	/* Userspace would break if executables appear on sysfs */
+	sb->s_iflags |= SB_I_NOEXEC;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = magic;
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index f31e36994dfb..20b8f82e115b 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -41,8 +41,7 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 	if (IS_ERR(root) || !new_sb)
 		kobj_ns_drop(KOBJ_NS_TYPE_NET, ns);
 	else if (new_sb)
-		/* Userspace would break if executables appear on sysfs */
-		root->d_sb->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC;
+		root->d_sb->s_iflags |= SB_I_USERNS_VISIBLE;
 
 	return root;
 }
-- 
2.8.3
