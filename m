From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11] cgroup: disallow rename(2) if
	sane_behavior
Date: Fri, 14 Jun 2013 15:44:42 +0800
Message-ID: <51BAC9EA.7020100@huawei.com>
References: <20130614034717.GA31533@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130614034717.GA31533-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/6/14 11:47, Tejun Heo wrote:
> cgroup's rename(2) isn't a proper migration implementation - it can't
> move the cgroup to a different parent in the hierarchy.  All it can do
> is swapping the name string for that cgroup.  This isn't useful and
> can mislead users to think that cgroup supports proper cgroup-level
> migration.  Disallow rename(2) if sane_behavior.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  include/linux/cgroup.h |    2 ++
>  kernel/cgroup.c        |    7 +++++++
>  2 files changed, 9 insertions(+)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 1760476..f975227 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -270,6 +270,8 @@ enum {
>  	 * - "release_agent" and "notify_on_release" are removed.
>  	 *   Replacement notification mechanism will be implemented.
>  	 *
> +	 * - rename(2) is disallowed.
> +	 *
>  	 * - memcg: use_hierarchy is on by default and the cgroup file for
>  	 *   the flag is not created.
>  	 */
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 2e9da7b..7d78902 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2508,6 +2508,13 @@ static int cgroup_rename(struct inode *old_dir, struct dentry *old_dentry,
>  
>  	cgrp = __d_cgrp(old_dentry);
>  
> +	/*
> +	 * This isn't a proper migration and its usefulness is very
> +	 * limited.  Disallow if sane_behavior.
> +	 */
> +	if (cgroup_sane_behavior(cgrp))
> +		return -EINVAL;
> +

Isn't -EPERM a better errno? VFS will return -EPERM if inode->rename is NULL.

>  	name = cgroup_alloc_name(new_dentry);
>  	if (!name)
>  		return -ENOMEM;
