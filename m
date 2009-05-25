From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] cgroups: handle failure of cgroup_populate_dir() at
	mount/remount
Date: Mon, 25 May 2009 21:17:53 +0800
Message-ID: <20090525131753.GL4858__1563.67238746515$1243257647$gmane$org@balbir.in.ibm.com>
References: <4A16153C.2080004@cn.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A16153C.2080004-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

* Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> [2009-05-22 11:00:12]:

> Now we have 'stat' file in both memory and cpuacct subsystems. If we
> mount these 2 subsystems with option 'noprefix', the creation of 'stat'
> file for cpuacct will fail, but without any notificatin to the user.
> 
> With this patch, we fail the mount/remount in this case.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup.c |   18 ++++++++++++++++--
>  1 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index a7267bf..eab83f7 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -896,6 +896,7 @@ static int parse_cgroupfs_options(char *data,
>  static int cgroup_remount(struct super_block *sb, int *flags, char *data)
>  {
>  	int ret = 0;
> +	unsigned long subsys_bits;
>  	struct cgroupfs_root *root = sb->s_fs_info;
>  	struct cgroup *cgrp = &root->top_cgroup;
>  	struct cgroup_sb_opts opts;
> @@ -914,12 +915,17 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
>  		goto out_unlock;
>  	}
> 
> +	subsys_bits = root->subsys_bits;
>  	ret = rebind_subsystems(root, opts.subsys_bits);
>  	if (ret)
>  		goto out_unlock;
> 
>  	/* (re)populate subsystem files */
> -	cgroup_populate_dir(cgrp);
> +	ret = cgroup_populate_dir(cgrp);
> +	if (ret) {

if (ret) means a failure right? So we rebind_subsystems to the older
subsys_bits? Could you please add a comment, the code can be misread.

> +		rebind_subsystems(root, subsys_bits);
> +		goto out_unlock;
> +	}
> 
>  	if (opts.release_agent)
>  		strcpy(root->release_agent_path, opts.release_agent);
> @@ -1122,9 +1128,13 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>  		BUG_ON(!list_empty(&root_cgrp->children));
>  		BUG_ON(root->number_of_cgroups != 1);
> 
> -		cgroup_populate_dir(root_cgrp);
> +		ret = cgroup_populate_dir(root_cgrp);
> +
>  		mutex_unlock(&inode->i_mutex);
>  		mutex_unlock(&cgroup_mutex);
> +
> +		if (ret)
> +			goto drop_new_super;
>  	}
> 
>  	simple_set_mnt(mnt, sb);
> @@ -1803,6 +1813,10 @@ int cgroup_add_file(struct cgroup *cgrp,
>  		dput(dentry);
>  	} else
>  		error = PTR_ERR(dentry);
> +
> +	if (error)
> +		printk(KERN_WARNING "cgroup: Failed to create file '%s': %d\n",
> +		       name, error);
>  	return error;
>  }
>

Looks good, should we mark cgroup_populate_dir with __must_check? 

-- 
	Balbir
