From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH tty-next 3/6] devpts: Simplify devpts_mount by using
	mount_nodev
Date: Wed, 14 Sep 2016 13:53:35 -0500
Message-ID: <20160914185338.15126-3-ebiederm@xmission.com>
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

Now that all of the work of setting up a superblock has been moved to
devpts_fill_super simplify devpts_mount by calling mount_nodev instead
of rolling mount_nodev by hand.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/devpts/inode.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 43773543a783..a48b40b0bd1e 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -451,24 +451,7 @@ fail:
 static struct dentry *devpts_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
-	int error;
-	struct super_block *s;
-
-	s = sget(fs_type, NULL, set_anon_super, flags, NULL);
-	if (IS_ERR(s))
-		return ERR_CAST(s);
-
-	if (!s->s_root) {
-		error = devpts_fill_super(s, data, flags & MS_SILENT ? 1 : 0);
-		if (error)
-			goto out_undo_sget;
-		s->s_flags |= MS_ACTIVE;
-	}
-	return dget(s->s_root);
-
-out_undo_sget:
-	deactivate_locked_super(s);
-	return ERR_PTR(error);
+	return mount_nodev(fs_type, flags, data, devpts_fill_super);
 }
 
 static void devpts_kill_sb(struct super_block *sb)
-- 
2.8.3
