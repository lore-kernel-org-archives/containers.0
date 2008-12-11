From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] CGroups: Fix a race between rmdir and remount
Date: Thu, 11 Dec 2008 10:23:43 +0800
Message-ID: <494079AF.3040704__4559.90130217305$1228962494$gmane$org@cn.fujitsu.com>
References: <6599ad830812101533r6cb007eeu5ef19499e278f6b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830812101533r6cb007eeu5ef19499e278f6b7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Fix a race between rmdir and remount
> 
> When a cgroup is removed, it's unlinked from its parent's children
> list, but not actually freed until the last dentry on it is released
> (at which point cgrp->root->number_of_cgroups is decremented).
> 
> Currently rebind_subsystems checks for the top cgroup's child list
> being empty in order to rebind subsystems into or out of a hierarchy -
> this can result in the set of subsystems bound to a hierarchy being
> different than the set of subsystems with state in the
> removed-but-not-freed cgroup.
> 
> The simplest fix for this is to forbid remounts that change the set of
> subsystems on a hierarchy that has removed-but-not-freed cgroups.
> 
> This bug can be reproduced via:
> 

Seems this bug is revealed by my patch:

cgroups-remove-some-redundant-null-checks.patch
(http://marc.info/?l=linux-mm-commits&m=122730918427045&w=2)

@@ -611,10 +611,8 @@ static void cgroup_diput(struct dentry *
...
-		for_each_subsys(cgrp->root, ss) {
-			if (cgrp->subsys[ss->subsys_id])
-				ss->destroy(ss, cgrp);
-		}
+		for_each_subsys(cgrp->root, ss)
+			ss->destroy(ss, cgrp);

But this patch is not guilty. :)

The original code leaked memory silently due to this race, if the remount
removes some subsystems from the hierarchy.

> mkdir /mnt/cg
> mount -t cgroup -o ns,freezer cgroup /mnt/cg
> mkdir /mnt/cg/foo
> sleep 1h < /mnt/cg/foo &
> rmdir /mnt/cg/foo
> mount -t cgroup -o remount,ns,devices,freezer cgroup /mnt/cg
> kill $!
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

> ---
>  kernel/cgroup.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
> ===================================================================
> --- hierarchy_lock-mmotm-2008-12-09.orig/kernel/cgroup.c
> +++ hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
> @@ -702,7 +702,7 @@ static int rebind_subsystems(struct cgro
>  	 * any child cgroups exist. This is theoretically supportable
>  	 * but involves complex error handling, so it's being left until
>  	 * later */
> -	if (!list_empty(&cgrp->children))
> +	if (root->number_of_cgroups > 1)
>  		return -EBUSY;
> 
>  	/* Process each subsystem */
