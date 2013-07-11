From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/9] cgroup: make rebind_subsystems() handle file additions
	and removals with proper error handling
Date: Thu, 11 Jul 2013 15:09:46 +0800
Message-ID: <51DE5A3A.80708@huawei.com>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
	<1372463145-4245-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

> @@ -1651,26 +1647,32 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
>  		if (ret)
>  			goto unlock_drop;
>  
> +		sb->s_root->d_fsdata = root_cgrp;
> +		root_cgrp->dentry = sb->s_root;
> +
> +		cred = override_creds(&init_cred);
> +
> +		ret = cgroup_addrm_files(root_cgrp, NULL, cgroup_base_files, true);
> +		if (ret)
> +			goto rm_base_files;

if (ret) {
	free_cgrp_cset_links(&tmp_links);
	goto ...
}

> +
>  		ret = rebind_subsystems(root, root->subsys_mask, 0);
> -		if (ret == -EBUSY) {
> +		if (ret) {
>  			free_cgrp_cset_links(&tmp_links);
> -			goto unlock_drop;
> +			goto rm_base_files;
>  		}
