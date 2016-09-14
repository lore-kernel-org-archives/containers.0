From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH tty-next 1/6] devpts: Move parse_mount_options into fill_super
Date: Wed, 14 Sep 2016 13:53:33 -0500
Message-ID: <20160914185338.15126-1-ebiederm@xmission.com>
References: <87sht25n73.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87sht25n73.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/devpts/inode.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 79a5941c2474..c59d39f2d512 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -395,6 +395,7 @@ static int
 devpts_fill_super(struct super_block *s, void *data, int silent)
 {
 	struct inode *inode;
+	int error;
 
 	s->s_iflags &= ~SB_I_NODEV;
 	s->s_blocksize = 1024;
@@ -403,10 +404,16 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 	s->s_op = &devpts_sops;
 	s->s_time_gran = 1;
 
+	error = -ENOMEM;
 	s->s_fs_info = new_pts_fs_info(s);
 	if (!s->s_fs_info)
 		goto fail;
 
+	error = parse_mount_options(data, PARSE_MOUNT, &DEVPTS_SB(s)->mount_opts);
+	if (error)
+		goto fail;
+
+	error = -ENOMEM;
 	inode = new_inode(s);
 	if (!inode)
 		goto fail;
@@ -424,7 +431,7 @@ devpts_fill_super(struct super_block *s, void *data, int silent)
 	pr_err("get root dentry failed\n");
 
 fail:
-	return -ENOMEM;
+	return error;
 }
 
 /*
@@ -437,13 +444,8 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
 	int error;
-	struct pts_mount_opts opts;
 	struct super_block *s;
 
-	error = parse_mount_options(data, PARSE_MOUNT, &opts);
-	if (error)
-		return ERR_PTR(error);
-
 	s = sget(fs_type, NULL, set_anon_super, flags, NULL);
 	if (IS_ERR(s))
 		return ERR_CAST(s);
@@ -455,8 +457,6 @@ static struct dentry *devpts_mount(struct file_system_type *fs_type,
 		s->s_flags |= MS_ACTIVE;
 	}
 
-	memcpy(&(DEVPTS_SB(s))->mount_opts, &opts, sizeof(opts));
-
 	error = mknod_ptmx(s);
 	if (error)
 		goto out_undo_sget;
-- 
2.8.3
