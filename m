From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v9 1/4] fuse: Remove the buggy retranslation of pids in
	fuse_dev_do_read
Date: Thu,  8 Mar 2018 15:24:27 -0600
Message-ID: <20180308212430.7053-1-ebiederm__10961.9663715877$1520544429$gmane$org@xmission.com>
References: <87ina6ntx0.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ina6ntx0.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

At the point of fuse_dev_do_read the user space process that initiated the
action on the fuse filesystem may no longer exist.  The process have been
killed or may have fired an asynchronous request and exited.

If the initial process has exited the code "pid_vnr(find_pid_ns(in->h.pid,
fc->pid_ns)" will either return a pid of 0, or in the unlikely event that
the pid has been reallocated it can return practically any pid.  Any pid is
possible as the pid allocator allocates pid numbers in different pid
namespaces independently.

The only way to make translation in fuse_dev_do_read reliable is to call
get_pid in fuse_req_init_context, and pid_vnr followed by put_pid in
fuse_dev_do_read.  That reference counting in other contexts has been shown
to bounce cache lines between processors and in general be slow.  So that is
not desirable.

The only known user of running the fuse server in a different pid namespace
from the filesystem does not care what the pids are in the fuse messages
so removing this code should not matter.

Getting the translation to a server running outside of the pid namespace
of a container can still be achieved by playing setns games at mount time.
It is also possible to add an option to pass a pid namespace into the fuse
filesystem at mount time.

Fixes: 5d6d3a301c4e ("fuse: allow server to run in different pid_ns")
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/fuse/dev.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 5d06384c2cae..0fb58f364fa6 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1260,12 +1260,6 @@ static ssize_t fuse_dev_do_read(struct fuse_dev *fud, struct file *file,
 	in = &req->in;
 	reqsize = in->h.len;
 
-	if (task_active_pid_ns(current) != fc->pid_ns) {
-		rcu_read_lock();
-		in->h.pid = pid_vnr(find_pid_ns(in->h.pid, fc->pid_ns));
-		rcu_read_unlock();
-	}
-
 	/* If request is too large, reply with an error and restart the read */
 	if (nbytes < reqsize) {
 		req->out.h.error = -EIO;
-- 
2.14.1
