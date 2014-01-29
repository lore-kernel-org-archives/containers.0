From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 6/8] cgroup: remove cgroup->name
Date: Wed, 29 Jan 2014 13:09:07 +0100
Message-ID: <20140129120907.GA22183__3678.26862861893$1390997365$gmane$org@dhcp22.suse.cz>
References: <1390953585-16554-1-git-send-email-tj@kernel.org>
	<1390953585-16554-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1390953585-16554-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue 28-01-14 18:59:43, Tejun Heo wrote:
> cgroup->name handling became quite complicated over time involving
> dedicated struct cgroup_name for RCU protection.  Now that cgroup is
> on kernfs, we can drop all of it and simply use kernfs_name/path() and
> friends.  Replace cgroup->name and all related code with kernfs
> name/path constructs.
> 
> * Reimplement cgroup_name() and cgroup_path() as thin wrappers on top
>   of kernfs counterparts, which involves semantic changes.
>   pr_cont_cgroup_name() and pr_cont_cgroup_path() added.
> 
> * cgroup->name handling dropped from cgroup_rename().
> 
> * All users of cgroup_name/path() updated to the new semantics.  Users
>   which were formatting the string just to printk them are converted
>   to use pr_cont_cgroup_name/path() instead, which simplifies things
>   quite a bit.  As cgroup_name() no longer requires RCU read lock
>   around it, RCU lockings which were protecting only cgroup_name() are
>   removed.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Nice. I hated the way how we retrieved the name previously.
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Btw. after this change we should drop part of the comment above
oom_info_lock:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 19d5d4274e22..d998baec5deb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1684,8 +1684,7 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 	/*
-	 * protects memcg_name and makes sure that parallel ooms do not
-	 * interleave
+	 * Makes sure that parallel ooms do not interleave
 	 */
 	static DEFINE_SPINLOCK(oom_info_lock);
 	struct cgroup *task_cgrp;
-- 
Michal Hocko
SUSE Labs
