From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup_rm_file: don't delete the uncreated files
Date: Thu, 6 Dec 2012 14:02:45 +0800
Message-ID: <50C03505.3070801__48133.4271877587$1354773848$gmane$org@huawei.com>
References: <1354763350-3139-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1354763350-3139-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012/12/6 11:09, Gao feng wrote:
> in cgroup_add_file,when creating files for cgroup,
> some of creation may be skipped. So we need to avoid
> deleting these uncreated files in cgroup_rm_file,
> otherwise the warning msg will be triggered.
> 
> "cgroup_addrm_files: failed to remove memory_pressure_enabled, err=-2"
> 
> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 5cc3724..6928b3e 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -932,6 +932,12 @@ static int cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
>  	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
>  	lockdep_assert_held(&cgroup_mutex);
>  
> +	/* does @cft->flags tell us this file isn't created on @cgrp? */
> +	if ((cft->flags & CFTYPE_NOT_ON_ROOT) && !cgrp->parent)
> +		return 0;
> +	if ((cft->flags & CFTYPE_ONLY_ON_ROOT) && cgrp->parent)
> +		return 0;
> +

We should move those checks to cgroup_addrm_files() to avoid code duplication.

>  	list_for_each_entry(cfe, &cgrp->files, node) {
>  		struct dentry *d = cfe->dentry;
>  
> 
