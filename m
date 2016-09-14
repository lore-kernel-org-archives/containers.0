From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH tty-next 2/6] devpts: Move the creation of /dev/pts/ptmx into
	fill_super
Date: Wed, 14 Sep 2016 13:53:34 -0500
Message-ID: <20160914185338.15126-2-ebiederm@xmission.com>
References: <87sht25n73.fsf@x220.int.ebiederm.org>
	<20160914185338.15126-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160914185338.15126-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

The code makes more sense here and things are just clearer.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/devpts/inode.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index c59d39f2d512..43773543a783 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -425,11 +425,19 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 	set_nlink(inode, 2);
 
 	s->s_root = d_make_root(inode);
-	if (s->s_root)
-		return 0;
+	if (!s->s_root) {
+		pr_err("get root dentry failed\n");
+		goto fail;
+	}
 
-	pr_err("get root dentry failed\n");
+	error = mknod_ptmx(s);
+	if (error)
+		goto fail_dput;
 
+	return 0;
+fail_dput:
+	dput(s->s_root);
+	s->s_root = NULL;
 fail:
 	return error;
 }
@@ -456,11 +464,6 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
 			goto out_undo_sget;
 		s->s_flags |= MS_ACTIVE;
 	}
-
-	error = mknod_ptmx(s);
-	if (error)
-		goto out_undo_sget;
-
 	return dget(s->s_root);
 
 out_undo_sget:
-- 
2.8.3
