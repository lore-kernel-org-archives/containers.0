From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH]: Factor out PTY index allocation
Date: Thu, 17 Apr 2008 14:17:25 -0700
Message-ID: <20080417141725.7cd8e50e.akpm@linux-foundation.org>
References: <20080416221723.GB7112@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080416221723.GB7112-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 16 Apr 2008 15:17:23 -0700
sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:

> Factor out the code used to allocate/free a pts index into new interfaces,
> devpts_new_index() and devpts_kill_index().  This localizes the external
> data structures used in managing the pts indices.

err...

> -	mutex_lock(&allocated_ptys_lock);
> +	down(&allocated_ptys_lock);

Why the mutex-to-semaphore conversion?


--- a/fs/devpts/inode.c~devpts-factor-out-pty-index-allocation-fix
+++ a/fs/devpts/inode.c
@@ -17,6 +17,7 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/tty.h>
+#include <linux/mutex.h>
 #include <linux/idr.h>
 #include <linux/devpts_fs.h>
 #include <linux/parser.h>
@@ -29,7 +30,7 @@
 
 extern int pty_limit;			/* Config limit on Unix98 ptys */
 static DEFINE_IDR(allocated_ptys);
-static DECLARE_MUTEX(allocated_ptys_lock);
+static DEFINE_MUTEX(allocated_ptys_lock);
 
 static struct vfsmount *devpts_mnt;
 static struct dentry *devpts_root;
@@ -186,10 +187,10 @@ retry:
 		return -ENOMEM;
 	}
 
-	down(&allocated_ptys_lock);
+	mutex_lock(&allocated_ptys_lock);
 	idr_ret = idr_get_new(&allocated_ptys, NULL, &index);
 	if (idr_ret < 0) {
-		up(&allocated_ptys_lock);
+		mutex_unlock(&allocated_ptys_lock);
 		if (idr_ret == -EAGAIN)
 			goto retry;
 		return -EIO;
@@ -197,18 +198,18 @@ retry:
 
 	if (index >= pty_limit) {
 		idr_remove(&allocated_ptys, index);
-		up(&allocated_ptys_lock);
+		mutex_unlock(&allocated_ptys_lock);
 		return -EIO;
 	}
-	up(&allocated_ptys_lock);
+	mutex_unlock(&allocated_ptys_lock);
 	return index;
 }
 
 void devpts_kill_index(int idx)
 {
-	down(&allocated_ptys_lock);
+	mutex_lock(&allocated_ptys_lock);
 	idr_remove(&allocated_ptys, idx);
-	up(&allocated_ptys_lock);
+	mutex_unlock(&allocated_ptys_lock);
 }
 
 int devpts_pty_new(struct tty_struct *tty)
_
