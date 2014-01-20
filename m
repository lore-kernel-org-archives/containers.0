From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: clean up cgroup_subsys names and
	initialization
Date: Mon, 20 Jan 2014 14:13:37 +0100
Message-ID: <20140120131337.GD2626__32402.7448347353$1390223635$gmane$org@dhcp22.suse.cz>
References: <1389982317-22225-1-git-send-email-tj@kernel.org>
	<1389982317-22225-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1389982317-22225-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri 17-01-14 13:11:54, Tejun Heo wrote:
> cgroup_subsys is a bit messier than it needs to be.
> 
> * The name of a subsys can be different from its internal identifier
>   defined in cgroup_subsys.h.  Most subsystems use the matching name
>   but three - cpu, memory and perf_event - use different ones.
> 
> * cgroup_subsys_id enums are postfixed with _subsys_id and each
>   cgroup_subsys is postfixed with _subsys.  cgroup.h is widely
>   included throughout various subsystems, it doesn't and shouldn't
>   have claim on such generic names which don't have any qualifier
>   indicating that they belong to cgroup.
> 
> * cgroup_subsys->subsys_id should always equal the matching
>   cgroup_subsys_id enum; however, we require each controller to
>   initialize it and then BUG if they don't match, which is a bit
>   silly.
> 
> This patch cleans up cgroup_subsys names and initialization by doing
> the followings.
> 
> * cgroup_subsys_id enums are now postfixed with _cgrp_id, and each
>   cgroup_subsys with _cgrp_subsys.
> 
> * With the above, renaming subsys identifiers to match the userland
>   visible names doesn't cause any naming conflicts.  All non-matching
>   identifiers are renamed to match the official names.
> 
>   cpu_cgroup -> cpu
>   mem_cgroup -> memory
>   perf -> perf_event
> 
> * controllers no longer need to initialize ->subsys_id and ->name.
>   They're generated in cgroup core and set automatically during boot.
> 
> * Redundant cgroup_subsys declarations removed.
> 
> * While updating BUG_ON()s in cgroup_init_early(), convert them to
>   WARN()s.  BUGging that early during boot is stupid - the kernel
>   can't print anything, even through serial console and the trap
>   handler doesn't even link stack frame properly for back-tracing.
> 
> This patch doesn't introduce any behavior changes.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

For memcg and hugetlb
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

[...]

Thanks!
-- 
Michal Hocko
SUSE Labs
