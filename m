From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: [Patch resend v3 1/3] fs: add filp_clone_open API
Date: Tue, 19 Apr 2016 08:27:32 -0400
Message-ID: <1461068852.2435.3.camel__11000.5192029805$1461068865$gmane$org@HansenPartnership.com>
References: <1461068670.2435.0.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1461068670.2435.0.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

I need an API that allows me to obtain a clone of the current file
pointer to pass in to an exec handler.  I've labelled this as an
internal API because I can't see how it would be useful outside of the
fs subsystem.  The use case will be a persistent binfmt_misc handler.

Signed-off-by: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Acked-by: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
---
 fs/internal.h |  1 +
 fs/open.c     | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/fs/internal.h b/fs/internal.h
index b71deee..c8ca0c9 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -108,6 +108,7 @@ extern long do_handle_open(int mountdirfd,
 			   struct file_handle __user *ufh, int open_flag);
 extern int open_check_o_direct(struct file *f);
 extern int vfs_open(const struct path *, struct file *, const struct cred *);
+extern struct file *filp_clone_open(struct file *);
 
 /*
  * inode.c
diff --git a/fs/open.c b/fs/open.c
index 17cb6b1..bfe6f2b 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -1002,6 +1002,26 @@ struct file *file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 }
 EXPORT_SYMBOL(file_open_root);
 
+struct file *filp_clone_open(struct file *oldfile)
+{
+	struct file *file;
+	int retval;
+
+	file = get_empty_filp();
+	if (IS_ERR(file))
+		return file;
+
+	file->f_flags = oldfile->f_flags;
+	retval = vfs_open(&oldfile->f_path, file, oldfile->f_cred);
+	if (retval) {
+		put_filp(file);
+		return ERR_PTR(retval);
+	}
+
+	return file;
+}
+EXPORT_SYMBOL(filp_clone_open);
+
 long do_sys_open(int dfd, const char __user *filename, int flags, umode_t mode)
 {
 	struct open_flags op;
-- 
2.6.6
