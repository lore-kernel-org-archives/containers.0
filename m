From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a mount point
Date: Tue, 26 Nov 2013 16:16:13 -0800
Message-ID: <8738mi1yya.fsf_-_@xmission.com>
References: <20131115164123.GN28794@redhat.com>
	<20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com> <87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87siui1z1g.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 26 Nov 2013 16:14:19 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Aditya Kali (adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) wrote:
> Commit bf056bfa80596a5d14b26b17276a56a0dcb080e5:
> "proc: Fix the namespace inode permission checks." converted
> the namespace files into symlinks. The same commit changed
> the way namespace bind mounts appear in /proc/mounts:
>   $ mount --bind /proc/self/ns/ipc /mnt/ipc
> Originally:
>   $ cat /proc/mounts | grep ipc
>   proc /mnt/ipc proc rw,nosuid,nodev,noexec 0 0
>
> After commit bf056bfa80596a5d14b26b17276a56a0dcb080e5:
>   $ cat /proc/mounts | grep ipc
>   proc ipc:[4026531839] proc rw,nosuid,nodev,noexec 0 0
>
> This breaks userspace which expects the 2nd field in
> /proc/mounts to be a valid path.

The symlink /proc/<pid>/ns/{ipc,mnt,net,pid,user,uts} point to
dentries allocated with d_alloc_pseudo that we can mount, and
that have interesting names printed out with d_dname.

When these files are bind mounted /proc/mounts is not currently
displaying the mount point correctly because d_dname is called instead
of just displaying the path where the file is mounted.

Solve this by adding an explicit check to distinguish mounted pseudo
inodes and unmounted pseudo inodes.  Unmounted pseudo inodes always
use mount of their filesstem as the mnt_root  in their path making
these two cases easy to distinguish.

CC: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4bdb300b16e2..f7282ebf1a37 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3061,8 +3061,13 @@ char *d_path(const struct path *path, char *buf, int buflen)
 	 * thus don't need to be hashed.  They also don't need a name until a
 	 * user wants to identify the object in /proc/pid/fd/.  The little hack
 	 * below allows us to generate a name for these objects on demand:
+	 *
+	 * Some pseudo inodes are mountable.  When they are mounted
+	 * path->dentry == path->mnt->mnt_root.  In that case don't call d_dname
+	 * and instead have d_path return the mounted path.
 	 */
-	if (path->dentry->d_op && path->dentry->d_op->d_dname)
+	if (path->dentry->d_op && path->dentry->d_op->d_dname &&
+	    (!IS_ROOT(path->dentry) || path->dentry != path->mnt->mnt_root))
 		return path->dentry->d_op->d_dname(path->dentry, buf, buflen);
 
 	rcu_read_lock();
-- 
1.7.5.4
