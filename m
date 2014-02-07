From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/4] vfs: Simply when d_alloc_dname is called.
Date: Thu, 06 Feb 2014 18:23:54 -0800
Message-ID: <877g97hd8l.fsf_-_@xmission.com>
References: <20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com> <20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
	<87a9glh838.fsf@xmission.com>
	<20131130224340.GA10323@ZenIV.linux.org.uk>
	<874n53gub7.fsf@xmission.com>
	<20140117083901.GA10323@ZenIV.linux.org.uk>
	<87iosrhdc0.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87iosrhdc0.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Thu, 06 Feb 2014 18:21:51 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


Now that all implementations of d_dname use d_alloc_psuedo only consider
calling d_dname on root dentries, as all dentries returned
d_alloc_pseudo by d_alloc_pseudo are root dentries.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 265e0ce9769c..c250d97befe4 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3056,18 +3056,14 @@ char *d_path(const struct path *path, char *buf, int buflen)
 	int error;
 
 	/*
-	 * We have various synthetic filesystems that never get mounted.  On
-	 * these filesystems dentries are never used for lookup purposes, and
-	 * thus don't need to be hashed.  They also don't need a name until a
-	 * user wants to identify the object in /proc/pid/fd/.  The little hack
-	 * below allows us to generate a name for these objects on demand:
-	 *
-	 * Some pseudo inodes are mountable.  When they are mounted
-	 * path->dentry == path->mnt->mnt_root.  In that case don't call d_dname
-	 * and instead have d_path return the mounted path.
+	 * We have various synthetic files allocated with
+	 * d_alloc_pseudo that are not available through
+	 * ordinary path lookup and don't need a name until
+	 * a user wants to identify the object in
+	 * /proc/pid/fd/ or similiar.
 	 */
 	if (path->dentry->d_op && path->dentry->d_op->d_dname &&
-	    (!IS_ROOT(path->dentry) || path->dentry != path->mnt->mnt_root))
+	    IS_ROOT(path->dentry) && path->dentry != path->mnt->mnt_root)
 		return path->dentry->d_op->d_dname(path->dentry, buf, buflen);
 
 	rcu_read_lock();
-- 
1.7.5.4
