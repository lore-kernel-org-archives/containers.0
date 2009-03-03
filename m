From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] cgroups: show correct file mode
Date: Tue, 3 Mar 2009 12:27:33 -0800
Message-ID: <20090303122733.af5ceea9.akpm@linux-foundation.org>
References: <49ACC037.2090507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49ACC037.2090507-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 03 Mar 2009 13:29:27 +0800
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> 
> We have some read-only files and write-only files, but currently they
> are all set to 0644, which is counter-intuitive and cause trouble
> for some cgroup tools like libcgroup.
> 
> This patch adds 'mode' to struct cftype to allow cgroup subsys to set
> it's own files' file mode, and for the most cases cft->mode can be
> default to 0 and cgroup will figure out proper mode.
> 
> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  include/linux/cgroup.h |    5 +++++
>  kernel/cgroup.c        |   32 +++++++++++++++++++++++++++++++-
>  kernel/cpuset.c        |    1 +
>  3 files changed, 37 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 6ad1989..31cc1a9 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -258,6 +258,11 @@ struct cftype {
>  	 */
>  	char name[MAX_CFTYPE_NAME];
>  	int private;
> +	/*
> +	 * If not 0, file mode is set to this value, otherwise it will
> +	 * be figured out automatically
> +	 */
> +	int mode;

Could/should this (and everything else) have type mode_t?

>  	/*
>  	 * If non-zero, defines the maximum length of string that can
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 379baa3..043b24e 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1750,6 +1750,33 @@ static int cgroup_create_dir(struct cgroup *cgrp, struct dentry *dentry,
>  	return error;
>  }
>  
> +/**
> + * cgroup_file_mode - deduce file mode of a control file
> + * @cft: the control file in question
> + *
> + * returns cft->mode if ->mode is not 0
> + * returns 0644 if it has both a read and a write handler
> + * returns 0444 if it has only a read handler
> + * returns 0200 if it has only a write hander
> + */
> +static int cgroup_file_mode(const struct cftype *cft)
> +{
> +	int mode = 0;
> +
> +	if (cft->mode)
> +		return cft->mode;
> +
> +	if (cft->read || cft->read_u64 || cft->read_s64 ||
> +	    cft->read_map || cft->read_seq_string)
> +		mode |= 0444;

S_IRUGO?

> +	if (cft->write || cft->write_u64 || cft->write_s64 ||
> +	    cft->write_string || cft->trigger)
> +		mode |= 0200;

S_IWUSR?

> +	return mode;
> +}
> +
>  int cgroup_add_file(struct cgroup *cgrp,
>  		       struct cgroup_subsys *subsys,
>  		       const struct cftype *cft)
> @@ -1757,6 +1784,7 @@ int cgroup_add_file(struct cgroup *cgrp,
>  	struct dentry *dir = cgrp->dentry;
>  	struct dentry *dentry;
>  	int error;
> +	int mode;

mode_t.

>  	char name[MAX_CGROUP_TYPE_NAMELEN + MAX_CFTYPE_NAME + 2] = { 0 };
>  	if (subsys && !test_bit(ROOT_NOPREFIX, &cgrp->root->flags)) {
> @@ -1767,7 +1795,8 @@ int cgroup_add_file(struct cgroup *cgrp,
>  	BUG_ON(!mutex_is_locked(&dir->d_inode->i_mutex));
>  	dentry = lookup_one_len(name, dir, strlen(name));
>  	if (!IS_ERR(dentry)) {
> -		error = cgroup_create_file(dentry, 0644 | S_IFREG,
> +		mode = cgroup_file_mode(cft);
> +		error = cgroup_create_file(dentry, mode | S_IFREG,
>  						cgrp->root->sb);
>  		if (!error)
>  			dentry->d_fsdata = (void *)cft;
> @@ -2349,6 +2378,7 @@ static struct cftype files[] = {
>  		.write_u64 = cgroup_tasks_write,
>  		.release = cgroup_tasks_release,
>  		.private = FILE_TASKLIST,
> +		.mode = 0644,

S_IRUGO|S_IWUSR ?

>  	},
>  
>  	{
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index a46d693..31e28b3 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1678,6 +1678,7 @@ static struct cftype files[] = {
>  		.read_u64 = cpuset_read_u64,
>  		.write_u64 = cpuset_write_u64,
>  		.private = FILE_MEMORY_PRESSURE,
> +		.mode = 0444,

S_IRUGO?

>  	},
>  
>  	{
> -- 
> 1.5.4.rc3
> 
