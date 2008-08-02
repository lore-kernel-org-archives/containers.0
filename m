From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/6] user namespaces: add user_ns to super block
Date: Fri, 1 Aug 2008 19:06:09 -0500
Message-ID: <20080802000609.GA10211@us.ibm.com>
References: <20080726002700.GA29686@us.ibm.com>
	<20080726002754.GD29874@us.ibm.com>
	<m13altislf.fsf@frodo.ebiederm.org>
	<1217285230.25300.19.camel@localhost.localdomain>
	<20080729180515.GB365@us.ibm.com>
	<m13alscx7e.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m13alscx7e.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> >
> > The filesystem can figure that out based on current's context, no?
> >
> > With the per-sb user_ns, the default behavior is indeed very limited,
> > but since you want to move all the user_ns functionality into the
> > filesystem, the fs can tag vfsmounts based on the "new remount" you
> > had talked about before.
> 
> I guess I want the filesystem to coordinate.
> 
> >> 	Would this require passing the vfsmount to the filesystems themselves,
> >> or would they be within the VFS code only? If not wholly within the VFS
> >> I wonder if Al Viro would object to this. He's resisted past attempts to
> >> pass the vfsmount structs into more filesystem code paths and I'm
> >> guessing that could affect whether or not this approach can be
> >> implemented.
> >
> > Right, that's the main reason we might want to pursue the per-sb
> > approach.  Otherwise I would prefer the per-vfsmount approach.
> >
> > Eric, if you think the per-vfsmount fight is worth fighting, then by all
> > means let's do it and see what happens.  So in that case ignore patches
> > 3-5 from this set :)
> 
> My intuitive sense is that the treating the handling of different
> user namespaces in the same filesystem is a trivial case of the
> superblock merging that nfs performs.  And that we will preserve
> existing semantics much better if the user namespace is stored
> in the vfsmount.  This allows mount propagation and friends to work
> without surprises.
> 
> The practical limitation I see of storing things outside of the
> vfsmount is when do you setup the mapping to handle a new user
> namespace?
> 
> So yes.  I think it is worth the discussion.  Let's not
> move the vfsmount down, and just move the user namespace pointer
> down as that is fundamentally what we care about.
> 
> Eric

Ok I wasn't thinking right.  We still can't get to a user_ns from
an inode *.

So playing with this a bit tonight, it seems like the best way
to pass the user_namespace up to the fs is just to define new
super_operations which handle the conversions.  Something like
the following.

(This sits on top of the two patches I'm about to send out as
replacements for patches 1 and 2 from my previous posting.)

-serge

From 0156ae52302a70302b1725450fae7f565195410a Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Fri, 1 Aug 2008 18:55:59 -0500
Subject: [PATCH 3/3] user namespaces: enforce user namespaces for file permission

Add a user_ns to the sb.  It is always set to the user_ns of the task which
mounted the sb.

Define 3 new super_operations.  convert_uid() and convert_gid() take a uid
or gid from an inode on the sb's fs, and attempt to convert them into ids
meaningful in the user namespace passed in, which presumably is current's.
is_capable() checks whether current has the requested capability with respect
to the sb's fs, which is dependent upon the relationship between current's
user_ns and those which the sb knows about.

If the sb isn't user ns aware - which none are right now - then the new
super_operations won't be defined.  If in that case current and sb have
different user namespaces, then the userids can't be compared.

If current's and sb's userids can't be compared, then current will get
'user other' (we usually say 'nobody') permissions to the inode.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/namei.c         |   33 ++++++++++++++++++++++---
 fs/super.c         |    3 ++
 include/linux/fs.h |   68 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 4ea63ed..e17bc96 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -183,10 +183,32 @@ int generic_permission(struct inode *inode, int mask,
 		int (*check_acl)(struct inode *inode, int mask))
 {
 	umode_t			mode = inode->i_mode;
+	uid_t			iuid;
+	gid_t			igid;
+	int			ret;
+	int			good_userns = 1;
+	struct			super_block *sb = inode->i_sb;
+
+	ret = s_convert_uid(sb, current->user->user_ns,
+						inode->i_uid, &iuid);
+	if (!ret)
+		good_userns = 0;
+	ret = s_convert_gid(sb, current->user->user_ns,
+						inode->i_gid, &igid);
+	if (!ret)
+		good_userns = 0;
 
 	mask &= MAY_READ | MAY_WRITE | MAY_EXEC;
 
-	if (current->fsuid == inode->i_uid)
+	/*
+	 * If we're not in the inode's user namespace, we get
+	 * user nobody permissions, and we ignore acls
+	 * (bc serge doesn't know how to handle acls in this case)
+	 */
+	if (!good_userns)
+		goto check;
+
+	if (current->fsuid == iuid)
 		mode >>= 6;
 	else {
 		if (IS_POSIXACL(inode) && (mode & S_IRWXG) && check_acl) {
@@ -197,15 +219,18 @@ int generic_permission(struct inode *inode, int mask,
 				return error;
 		}
 
-		if (in_group_p(inode->i_gid))
+		if (in_group_p(igid))
 			mode >>= 3;
 	}
 
+check:
 	/*
 	 * If the DACs are ok we don't need any capability check.
 	 */
 	if ((mask & ~mode) == 0)
 		return 0;
+	if (!good_userns)
+		return -EACCES;
 
  check_capabilities:
 	/*
@@ -214,14 +239,14 @@ int generic_permission(struct inode *inode, int mask,
 	 */
 	if (!(mask & MAY_EXEC) ||
 	    (inode->i_mode & S_IXUGO) || S_ISDIR(inode->i_mode))
-		if (capable(CAP_DAC_OVERRIDE))
+		if (s_is_capable(sb, current->user->user_ns, CAP_DAC_OVERRIDE))
 			return 0;
 
 	/*
 	 * Searching includes executable on directories, else just read.
 	 */
 	if (mask == MAY_READ || (S_ISDIR(inode->i_mode) && !(mask & MAY_WRITE)))
-		if (capable(CAP_DAC_READ_SEARCH))
+		if (s_is_capable(sb, current->user->user_ns, CAP_DAC_READ_SEARCH))
 			return 0;
 
 	return -EACCES;
diff --git a/fs/super.c b/fs/super.c
index e931ae9..3559637 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -38,6 +38,7 @@
 #include <linux/kobject.h>
 #include <linux/mutex.h>
 #include <linux/file.h>
+#include <linux/user_namespace.h>
 #include <asm/uaccess.h>
 #include "internal.h"
 
@@ -93,6 +94,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		s->s_qcop = sb_quotactl_ops;
 		s->s_op = &default_op;
 		s->s_time_gran = 1000000000;
+		s->user_ns = get_user_ns(current->user->user_ns);
 	}
 out:
 	return s;
@@ -109,6 +111,7 @@ static inline void destroy_super(struct super_block *s)
 	security_sb_free(s);
 	kfree(s->s_subtype);
 	kfree(s->s_options);
+	put_user_ns(s->user_ns);
 	kfree(s);
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 580b513..a7cbcea 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1128,6 +1128,11 @@ struct super_block {
 	 * generic_show_options()
 	 */
 	char *s_options;
+
+	/*
+	 * namespace of the user which mounted the sb
+	 */
+	struct user_namespace *user_ns;
 };
 
 extern struct timespec current_fs_time(struct super_block *sb);
@@ -1320,6 +1325,9 @@ struct super_operations {
 	int (*remount_fs) (struct super_block *, int *, char *);
 	void (*clear_inode) (struct inode *);
 	void (*umount_begin) (struct super_block *);
+	int (*is_capable) (struct user_namespace *, int);
+	uid_t (*convert_uid)(struct user_namespace *, uid_t, uid_t *);
+	gid_t (*convert_gid)(struct user_namespace *, gid_t, gid_t *);
 
 	int (*show_options)(struct seq_file *, struct vfsmount *);
 	int (*show_stats)(struct seq_file *, struct vfsmount *);
@@ -1330,6 +1338,66 @@ struct super_operations {
 };
 
 /*
+ * In the next 3, i'm passing the user_ns in so that I don't need
+ * to know how to dereference struct user her (which would require
+ * #including sched.h).
+ * Note in particular that for instance in s_convert_uid, the uid is the
+ * inode->i_uid, while user_ns is current->user->user_ns.
+ */
+
+/*
+ * s_convert_uid: attempt to translate the inode's stored
+ * uid to a uid meaningful in user_ns passed in
+ * If possible, store the result in reuid and return 1
+ * Otherwise, return 0, meaningful the uid cannot be translated
+ */
+static inline int s_convert_uid(struct super_block *sb,
+		struct user_namespace *user_ns, uid_t uid, uid_t *retuid)
+{
+	if (sb->user_ns == user_ns) {
+		*retuid = uid;
+		return 1;
+	}
+	if (sb->s_op->convert_uid)
+		return sb->s_op->convert_uid(user_ns, uid, retuid);
+	return 0;
+}
+
+/*
+ * s_convert_gid: attempt to translate the inode's stored
+ * gid to a gid meaningful in user_ns passed in
+ * If possible, store the result in regid and return 1
+ * Otherwise, return 0, meaningful the gid cannot be translated
+ */
+static inline int s_convert_gid(struct super_block *sb,
+		struct user_namespace *user_ns, gid_t gid, gid_t *retgid)
+{
+	if (sb->user_ns == user_ns) {
+		*retgid = gid;
+		return 1;
+	}
+	if (sb->s_op->convert_gid)
+		return sb->s_op->convert_gid(user_ns, gid, retgid);
+	return 0;
+}
+
+/*
+ * s_is_capable: check whether current is capable with respect
+ * to the filesystem represented by sb.
+ *
+ * return 0 if false, 1 if true
+ */
+static inline int s_is_capable(struct super_block *sb,
+		struct user_namespace *user_ns, int cap)
+{
+	if (sb->user_ns == user_ns)
+		return capable(cap);
+	if (sb->s_op->is_capable)
+		return sb->s_op->is_capable(user_ns, cap);
+	return 0;
+}
+
+/*
  * Inode state bits.  Protected by inode_lock.
  *
  * Three bits determine the dirty state of the inode, I_DIRTY_SYNC,
-- 
1.5.4.3
