From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] devcgroup: skip superfluous checks when found the
	DEV_ALL elem
Date: Tue, 7 Apr 2009 21:55:05 -0500
Message-ID: <20090408025505.GA28159__16905.4829086692$1239159549$gmane$org@us.ibm.com>
References: <49DAE8E4.2030106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49DAE8E4.2030106-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Li Zefan (lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> While walking through the whitelist, if the DEV_ALL item is found,
> no more check is needed.

Right, because the DEV_ALL item always has all permissions.


> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks,
-serge

> ---
>  security/device_cgroup.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index 5fda7df..b8186ba 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -490,7 +490,7 @@ int devcgroup_inode_permission(struct inode *inode, int mask)
> 
>  	list_for_each_entry_rcu(wh, &dev_cgroup->whitelist, list) {
>  		if (wh->type & DEV_ALL)
> -			goto acc_check;
> +			goto found;
>  		if ((wh->type & DEV_BLOCK) && !S_ISBLK(inode->i_mode))
>  			continue;
>  		if ((wh->type & DEV_CHAR) && !S_ISCHR(inode->i_mode))
> @@ -499,11 +499,12 @@ int devcgroup_inode_permission(struct inode *inode, int mask)
>  			continue;
>  		if (wh->minor != ~0 && wh->minor != iminor(inode))
>  			continue;
> -acc_check:
> +
>  		if ((mask & MAY_WRITE) && !(wh->access & ACC_WRITE))
>  			continue;
>  		if ((mask & MAY_READ) && !(wh->access & ACC_READ))
>  			continue;
> +found:
>  		rcu_read_unlock();
>  		return 0;
>  	}
> @@ -527,7 +528,7 @@ int devcgroup_inode_mknod(int mode, dev_t dev)
> 
>  	list_for_each_entry_rcu(wh, &dev_cgroup->whitelist, list) {
>  		if (wh->type & DEV_ALL)
> -			goto acc_check;
> +			goto found;
>  		if ((wh->type & DEV_BLOCK) && !S_ISBLK(mode))
>  			continue;
>  		if ((wh->type & DEV_CHAR) && !S_ISCHR(mode))
> @@ -536,9 +537,10 @@ int devcgroup_inode_mknod(int mode, dev_t dev)
>  			continue;
>  		if (wh->minor != ~0 && wh->minor != MINOR(dev))
>  			continue;
> -acc_check:
> +
>  		if (!(wh->access & ACC_MKNOD))
>  			continue;
> +found:
>  		rcu_read_unlock();
>  		return 0;
>  	}
> -- 
> 1.5.4.rc3
