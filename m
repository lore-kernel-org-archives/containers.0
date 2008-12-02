From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 3/4] checkpoint/restart: fix 'struct file' references
Date: Tue, 02 Dec 2008 10:57:39 -0800
Message-ID: <20081202185739.15E85A9A@kernel>
References: <20081202185734.F740150C@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081202185734.F740150C@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


We must hold a reference to 'file' when it get passed in to
fd_install().  After fd_install() the entry in the fdtable
takes on the reference.  If we don't hold a reference to
it, another thread can come along after fd_install() and
fput() it before we've done the get_file().

In cr_read_fd_data(), the cr_obj_add_ref() code does the
get_file() internally.  But, we need to do this (and get
the ref) before we do the cr_attach_file().  Otherwise,
the file can go away after the cr_attach_file() and before
the cr_obj_add_ref().


---

 linux-2.6.git-dave/checkpoint/rstr_file.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff -puN checkpoint/rstr_file.c~fix-refs-order-in-cr_attach_get_file checkpoint/rstr_file.c
--- linux-2.6.git/checkpoint/rstr_file.c~fix-refs-order-in-cr_attach_get_file	2008-12-02 10:22:17.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/rstr_file.c	2008-12-02 10:22:17.000000000 -0800
@@ -59,8 +59,8 @@ static int cr_attach_get_file(struct fil
 
 	if (fd >= 0) {
 		fsnotify_open(file->f_path.dentry);
-		fd_install(fd, file);
 		get_file(file);
+		fd_install(fd, file);
 	}
 	return fd;
 }
@@ -107,6 +107,11 @@ cr_read_fd_data(struct cr_ctx *ctx, stru
 
 	/* FIX: need to restore uid, gid, owner etc */
 
+	/* register new <objref, file> tuple in hash table */
+	ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
+	if (ret < 0)
+		goto out;
+
 	fd = cr_attach_file(file);	/* no need to cleanup 'file' below */
 	if (fd < 0) {
 		filp_close(file, NULL);
@@ -114,10 +119,6 @@ cr_read_fd_data(struct cr_ctx *ctx, stru
 		goto out;
 	}
 
-	/* register new <objref, file> tuple in hash table */
-	ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
-	if (ret < 0)
-		goto out;
 	ret = sys_fcntl(fd, F_SETFL, hh->f_flags & CR_SETFL_MASK);
 	if (ret < 0)
 		goto out;
_
