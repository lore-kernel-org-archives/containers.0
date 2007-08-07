From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 14/25] sysfs: Don't use lookup_one_len_kern
Date: Tue, 07 Aug 2007 15:23:57 -0600
Message-ID: <m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com>
	<m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com>
	<m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1lkcnhwfu.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:22:13 -0600")
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


Upon inspection it appears that there is no looking of the
inode mutex in lookup_one_len_kern and we aren't calling
it with the inode mutex and that is wrong.

So this patch rolls our own dcache insertion function that
does exactly what we need it to do.  As it turns out this
is pretty trivial to do and it makes the code easier to
audit.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c |   41 +++++++++++++++++++++++++++++++++++++++--
 1 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index a9bdb12..1d53c2a 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -765,6 +765,44 @@ static struct dentry *__sysfs_get_dentry(struct super_block *sb, struct sysfs_di
 	return dentry;
 }
 
+static struct dentry *sysfs_add_dentry(struct dentry *parent, struct sysfs_dirent *sd)
+{
+	struct qstr name;
+	struct dentry *dentry;
+	struct inode *inode;
+
+	mutex_lock(&parent->d_inode->i_mutex);
+	mutex_lock(&sysfs_mutex);
+	dentry = ERR_PTR(-EINVAL);
+	if (parent->d_fsdata != sd->s_parent)
+		goto out;
+
+	name.name = sd->s_name;
+	name.len = strlen(sd->s_name);
+	dentry = d_hash_and_lookup(parent, &name);
+	if (dentry)
+		goto out;
+
+	dentry = d_alloc(parent, &name);
+	if (!dentry) {
+		dentry = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+
+	inode = sysfs_get_inode(sd);
+	if (!inode) {
+		dput(dentry);
+		dentry = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	d_instantiate(dentry, inode);
+	sysfs_attach_dentry(sd, dentry);
+out:
+	mutex_unlock(&sysfs_mutex);
+	mutex_unlock(&parent->d_inode->i_mutex);
+	return dentry;
+}
+
 /**
  *	sysfs_get_dentry - get dentry for the given sysfs_dirent
  *	@sd: sysfs_dirent of interest
@@ -806,8 +844,7 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
 
 		/* look it up */
 		parent_dentry = dentry;
-		dentry = lookup_one_len_kern(cur->s_name, parent_dentry,
-					     strlen(cur->s_name));
+		dentry = sysfs_add_dentry(parent_dentry, cur);
 		dput(parent_dentry);
 
 		if (IS_ERR(dentry))
-- 
1.5.1.1.181.g2de0
