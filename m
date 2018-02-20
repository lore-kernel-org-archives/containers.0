From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 08/11] fuse: Support fuse filesystems outside of
	init_user_ns
Date: Mon, 19 Feb 2018 20:12:42 -0600
Message-ID: <877er8if39.fsf@xmission.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<c85c293e19a478353aba8e6e3ee39e5914f798d5.1512041070.git.dongsu@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c85c293e19a478353aba8e6e3ee39e5914f798d5.1512041070.git.dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
	(Dongsu Park's message of "Fri, 22 Dec 2017 15:32:32 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> writes:

> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> In order to support mounts from namespaces other than
> init_user_ns, fuse must translate uids and gids to/from the
> userns of the process servicing requests on /dev/fuse. This
> patch does that, with a couple of restrictions on the namespace:
>
>  - The userns for the fuse connection is fixed to the namespace
>    from which /dev/fuse is opened.
>
>  - The namespace must be the same as s_user_ns.
>
> These restrictions simplify the implementation by avoiding the
> need to pass around userns references and by allowing fuse to
> rely on the checks in inode_change_ok for ownership changes.
> Either restriction could be relaxed in the future if needed.
>
> For cuse the namespace used for the connection is also simply
> current_user_ns() at the time /dev/cuse is opened.
>
> Patch v4 is available: https://patchwork.kernel.org/patch/8944661/
>
> Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
> ---
>  fs/fuse/cuse.c   |  3 ++-
>  fs/fuse/dev.c    | 11 ++++++++---
>  fs/fuse/dir.c    | 14 +++++++-------
>  fs/fuse/fuse_i.h |  6 +++++-
>  fs/fuse/inode.c  | 31 +++++++++++++++++++------------
>  5 files changed, 41 insertions(+), 24 deletions(-)
>
> diff --git a/fs/fuse/cuse.c b/fs/fuse/cuse.c
> index e9e97803..b1b83259 100644
> --- a/fs/fuse/cuse.c
> +++ b/fs/fuse/cuse.c
> @@ -48,6 +48,7 @@
>  #include <linux/stat.h>
>  #include <linux/module.h>
>  #include <linux/uio.h>
> +#include <linux/user_namespace.h>
>  
>  #include "fuse_i.h"
>  
> @@ -498,7 +499,7 @@ static int cuse_channel_open(struct inode *inode, struct file *file)
>  	if (!cc)
>  		return -ENOMEM;
>  
As noticed in the review this should probably say:
	if (current_user_ns() != &init_user_ns)
		return -EINVAL;

Just so we don't need to think about cuse being opened in a user
namespace at this point.  It is probably harmless.  But it isn't
what we are focusing on.

> -	fuse_conn_init(&cc->fc);
> +	fuse_conn_init(&cc->fc, current_user_ns());
>  
>  	fud = fuse_dev_alloc(&cc->fc);
>  	if (!fud) {


> diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
> index 17f0d05b..0f780e16 100644
> --- a/fs/fuse/dev.c
> +++ b/fs/fuse/dev.c
> @@ -114,8 +114,8 @@ static void __fuse_put_request(struct fuse_req *req)
>  
>  static void fuse_req_init_context(struct fuse_conn *fc, struct fuse_req *req)
>  {
> -	req->in.h.uid = from_kuid_munged(&init_user_ns, current_fsuid());
> -	req->in.h.gid = from_kgid_munged(&init_user_ns, current_fsgid());
> +	req->in.h.uid = from_kuid(fc->user_ns, current_fsuid());
> +	req->in.h.gid = from_kgid(fc->user_ns, current_fsgid());
>  	req->in.h.pid = pid_nr_ns(task_pid(current), fc->pid_ns);
>  }
>  
> @@ -167,6 +167,10 @@ static struct fuse_req *__fuse_get_req(struct fuse_conn *fc, unsigned npages,
>  	__set_bit(FR_WAITING, &req->flags);
>  	if (for_background)
>  		__set_bit(FR_BACKGROUND, &req->flags);
> +	if (req->in.h.uid == (uid_t)-1 || req->in.h.gid == (gid_t)-1) {
> +		fuse_put_request(fc, req);
> +		return ERR_PTR(-EOVERFLOW);
> +	}
>  
>  	return req;
>  
> @@ -1260,7 +1264,8 @@ static ssize_t fuse_dev_do_read(struct fuse_dev *fud, struct file *file,
>  	in = &req->in;
>  	reqsize = in->h.len;
>  
> -	if (task_active_pid_ns(current) != fc->pid_ns) {
> +	if (task_active_pid_ns(current) != fc->pid_ns ||
> +	    current_user_ns() != fc->user_ns) {
>  		rcu_read_lock();
>  		in->h.pid = pid_vnr(find_pid_ns(in->h.pid, fc->pid_ns));
>  		rcu_read_unlock();

The hunk above is a rebase error.  I believe it started out by erroring
out in the same case the pid namespace case errored out.  Miklos has a
good point that we need to handle the case where we have servers running
in jails of one sort or another because at least sandstorm runs
applications in that fashion, and we have previously had error reports
about that configuration breaking.

I think we can easily fix that.  Either by adding extra translation as
we did for the pid namespace or changing the user namespace used on the
connection.  I believe extra translation like we did with the pid
namespace will be more consistent.  And again it won't be a special
case except possibly during mount.  Of course there is weirdness there.

Eric
