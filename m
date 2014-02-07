From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 3/4] vfs: Move the call of d_op->d_dname from d_path to
	prepend_path
Date: Thu, 06 Feb 2014 18:24:27 -0800
Message-ID: <8738jvhd7o.fsf_-_@xmission.com>
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


For clarity move the call of d_dname from d_path into prepend_path.
There are only 4 callers of prepend_path and this change does not
affect the results returned by any of them.  d_absolute_path
and __d_path return an error and ignore the output of prepend_path
error == 2. getcwd only operates on directories and all of the
implementations of d_dname are on files.

For d_path the argument of no changes in output is a little trickier.
path_with_deleted does not trigger because pseudo dentries are match
IS_ROOT so is_unlinked is false.  All of current implementations of
d_dname are files so they are not currently anyone's d_parent, which
means today that either the first iteration of prepend_path will call
d_dname or none of the iterations of prepend_path will call d_dname.

d_dname is called from the while loop in prepend_path so that if it
happens in the future that any of the implementors of d_dname are a
directory instead of a file then prepend_path will work properly on them.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c |   32 +++++++++++++++++++++-----------
 1 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index c250d97befe4..c5c7847ff84b 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2892,6 +2892,27 @@ restart:
 	while (dentry != root->dentry || vfsmnt != root->mnt) {
 		struct dentry * parent;
 
+		/*
+		 * We have various synthetic files allocated with
+		 * d_alloc_pseudo that are not available through
+		 * ordinary path lookup and don't need a name until
+		 * a user wants to identify the object in
+		 * /proc/pid/fd/ or similiar.
+		 */
+		if (IS_ROOT(dentry) && dentry != vfsmnt->mnt_root &&
+		    dentry->d_op && dentry->d_op->d_dname) {
+			char *buf  = bptr - blen;
+			char *name = dentry->d_op->d_dname(dentry, buf, blen);
+			if (IS_ERR(name)) {
+				error = PTR_ERR(name);
+				break;
+			}
+			blen = name - buf;
+			bptr = name;
+			error = 2; /* unmounted by definition */
+			break;
+		}
+
 		if (dentry == vfsmnt->mnt_root || IS_ROOT(dentry)) {
 			struct mount *parent = ACCESS_ONCE(mnt->mnt_parent);
 			/* Global root? */
@@ -3055,17 +3076,6 @@ char *d_path(const struct path *path, char *buf, int buflen)
 	struct path root;
 	int error;
 
-	/*
-	 * We have various synthetic files allocated with
-	 * d_alloc_pseudo that are not available through
-	 * ordinary path lookup and don't need a name until
-	 * a user wants to identify the object in
-	 * /proc/pid/fd/ or similiar.
-	 */
-	if (path->dentry->d_op && path->dentry->d_op->d_dname &&
-	    IS_ROOT(path->dentry) && path->dentry != path->mnt->mnt_root)
-		return path->dentry->d_op->d_dname(path->dentry, buf, buflen);
-
 	rcu_read_lock();
 	get_fs_root_rcu(current->fs, &root);
 	error = path_with_deleted(path, &root, &res, &buflen);
-- 
1.7.5.4
