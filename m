From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 02/25] sysfs: Remove sysfs_instantiate
Date: Tue, 07 Aug 2007 15:08:50 -0600
Message-ID: <m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11wefkq88.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:08:07 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


Now that sysfs_get_inode is dropping the inode lock
we no longer have a need from sysfs_instantiate.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c   |    2 +-
 fs/sysfs/inode.c |   17 -----------------
 fs/sysfs/sysfs.h |    1 -
 3 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index ae06f4a..55d8299 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -771,7 +771,7 @@ static struct dentry * sysfs_lookup(struct inode *dir, struct dentry *dentry,
 		goto out_unlock;
 	}
 
-	sysfs_instantiate(dentry, inode);
+	d_instantiate(dentry, inode);
 	sysfs_attach_dentry(sd, dentry);
 
  out_unlock:
diff --git a/fs/sysfs/inode.c b/fs/sysfs/inode.c
index aefc346..70a2420 100644
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -212,23 +212,6 @@ struct inode * sysfs_get_inode(struct sysfs_dirent *sd)
 	return inode;
 }
 
-/**
- *	sysfs_instantiate - instantiate dentry
- *	@dentry: dentry to be instantiated
- *	@inode: inode associated with @sd
- *
- *	Unlock @inode if locked and instantiate @dentry with @inode.
- *
- *	LOCKING:
- *	None.
- */
-void sysfs_instantiate(struct dentry *dentry, struct inode *inode)
-{
-	BUG_ON(!dentry || dentry->d_inode);
-
-	d_instantiate(dentry, inode);
-}
-
 int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const char *name)
 {
 	struct sysfs_addrm_cxt acxt;
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 0436754..8a0aea1 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -69,7 +69,6 @@ extern void sysfs_remove_one(struct sysfs_addrm_cxt *acxt,
 extern void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt);
 
 extern struct inode * sysfs_get_inode(struct sysfs_dirent *sd);
-extern void sysfs_instantiate(struct dentry *dentry, struct inode *inode);
 
 extern void release_sysfs_dirent(struct sysfs_dirent * sd);
 extern struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
-- 
1.5.1.1.181.g2de0
