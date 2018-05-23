From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH v2 3/6] fs: Allow superblock owner to replace invalid
	owners of inodes
Date: Wed, 23 May 2018 18:41:29 -0500
Message-ID: <87bmd6549i.fsf_-___12786.9567288601$1527118798$gmane$org@xmission.com>
References: <87o9h6554f.fsf@xmission.com>
	<20180523232538.4880-3-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180523232538.4880-3-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric
	W. Biederman's message of "Wed, 23 May 2018 18:25:35 -0500")
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org


Allow users with CAP_SYS_CHOWN over the superblock of a filesystem to
chown files when inode owner is invalid.  Ordinarily the
capable_wrt_inode_uidgid check is sufficient to allow access to files
but when the underlying filesystem has uids or gids that don't map to
the current user namespace it is not enough, so the chown permission
checks need to be extended to allow this case.

Calling chown on filesystem nodes whose uid or gid don't map is
necessary if those nodes are going to be modified as writing back
inodes which contain uids or gids that don't map is likely to cause
filesystem corruption of the uid or gid fields.

Once chown has been called the existing capable_wrt_inode_uidgid
checks are sufficient to allow the owner of a superblock to do anything
the global root user can do with an appropriate set of capabilities.

An ordinary filesystem mountable by a userns root will limit all uids
and gids in s_user_ns or the INVALID_UID and INVALID_GID to flag all
others.  So having this added permission limited to just INVALID_UID
and INVALID_GID is sufficient to handle every case on an ordinary filesystem.

Of the virtual filesystems at least proc is known to set s_user_ns to
something other than &init_user_ns, while at the same time presenting
some files owned by GLOBAL_ROOT_UID.  Those files the mounter of proc
in a user namespace should not be able to chown to get access to.
Limiting the relaxation in permission to just the minimum of allowing
changing INVALID_UID and INVALID_GID prevents problems with cases like
that.

The original version of this patch was written by: Seth Forshee.  I
have rewritten and rethought this patch enough so it's really not the
same thing (certainly it needs a different description), but he
deserves credit for getting out there and getting the conversation
started, and finding the potential gotcha's and putting up with my
semi-paranoid feedback.

Inspired-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---

Sigh.  In simplifying this change so it would not require a change to
proc (or any other similar filesystem) I accidentally introduced some
badly placed semicolons.  The kbuild test robot was very nice and found
those for me.  Resend with those unnecessary semicolons removed.

 fs/attr.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 12ffdb6fb63c..d0b4d34878fb 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -18,6 +18,32 @@
 #include <linux/evm.h>
 #include <linux/ima.h>
 
+static bool chown_ok(const struct inode *inode, kuid_t uid)
+{
+	if (uid_eq(current_fsuid(), inode->i_uid) &&
+	    uid_eq(uid, inode->i_uid))
+		return true;
+	if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
+		return true;
+	if (uid_eq(inode->i_uid, INVALID_UID) &&
+	    ns_capable(inode->i_sb->s_user_ns, CAP_CHOWN))
+		return true;
+	return false;
+}
+
+static bool chgrp_ok(const struct inode *inode, kgid_t gid)
+{
+	if (uid_eq(current_fsuid(), inode->i_uid) &&
+	    (in_group_p(gid) || gid_eq(gid, inode->i_gid)))
+		return true;
+	if (capable_wrt_inode_uidgid(inode, CAP_CHOWN))
+		return true;
+	if (gid_eq(inode->i_gid, INVALID_GID) &&
+	    ns_capable(inode->i_sb->s_user_ns, CAP_CHOWN))
+		return true;
+	return false;
+}
+
 /**
  * setattr_prepare - check if attribute changes to a dentry are allowed
  * @dentry:	dentry to check
@@ -52,17 +78,11 @@ int setattr_prepare(struct dentry *dentry, struct iattr *attr)
 		goto kill_priv;
 
 	/* Make sure a caller can chown. */
-	if ((ia_valid & ATTR_UID) &&
-	    (!uid_eq(current_fsuid(), inode->i_uid) ||
-	     !uid_eq(attr->ia_uid, inode->i_uid)) &&
-	    !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
+	if ((ia_valid & ATTR_UID) && !chown_ok(inode, attr->ia_uid))
 		return -EPERM;
 
 	/* Make sure caller can chgrp. */
-	if ((ia_valid & ATTR_GID) &&
-	    (!uid_eq(current_fsuid(), inode->i_uid) ||
-	    (!in_group_p(attr->ia_gid) && !gid_eq(attr->ia_gid, inode->i_gid))) &&
-	    !capable_wrt_inode_uidgid(inode, CAP_CHOWN))
+	if ((ia_valid & ATTR_GID) && !chgrp_ok(inode, attr->ia_gid))
 		return -EPERM;
 
 	/* Make sure a caller can chmod. */
