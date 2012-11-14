From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/17] cgroup: create directory before linking while
	creating a new cgroup
Date: Wed, 14 Nov 2012 11:20:47 +0800
Message-ID: <50A30E0F.7000408@huawei.com>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
	<1352775704-9023-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012/11/13 11:01, Tejun Heo wrote:
> While creating a new cgroup, cgroup_create() links the newly allocated
> cgroup into various places before trying to create its directory.
> Because cgroup life-cycle is tied to the vfs objects, this makes it
> impossible to use cgroup_rmdir() for rolling back creation - the
> removal logic depends on having full vfs objects.
> 
> This patch moves directory creation above linking and collect linking
> operations to one place.  This allows directory creation failure to
> share error exit path with css allocation failures and any failure
> sites afterwards (to be added later) can use cgroup_rmdir() logic to
> undo creation.
> 

> It also removes the need to check whether cgroup->dentry is %NULL in
> cgroup_path.  If a cgroup is visible, its dentry is guaranteed to be
> visible too.
> 

I'm afraid this isn't safe.

The cgroup is visible to a controller soon after ss->create(), and then
the controller might call cgroup_path() while cgrp->dentry is still NULL.

This can happen for cpu cgroup I think, and in fact the NULL check was
added for this reason IIRC.

> Note that this also makes the memory barriers around cgroup->dentry,
> which currently is misleadingly using RCU operations, unnecessary.
> This will be handled in the next patch.
> 
> While at it, locking BUG_ON() on i_mutex is converted to
> lockdep_assert_held().
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  kernel/cgroup.c | 32 +++++++++++++-------------------
>  1 file changed, 13 insertions(+), 19 deletions(-)
