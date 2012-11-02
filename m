From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 5/8] cgroup: remove CGRP_WAIT_ON_RMDIR,
	cgroup_exclude_rmdir() and cgroup_release_and_wakeup_rmdir()
Date: Fri, 02 Nov 2012 19:20:38 +0900
Message-ID: <50939E76.1000801__8618.31937586448$1351851679$gmane$org@jp.fujitsu.com>
References: <1351712650-23709-1-git-send-email-tj@kernel.org>
	<1351712650-23709-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351712650-23709-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/11/01 4:44), Tejun Heo wrote:
> CGRP_WAIT_ON_RMDIR is another kludge which was added to make cgroup
> destruction rollback somewhat working.  cgroup_rmdir() used to drain
> CSS references and CGRP_WAIT_ON_RMDIR and the associated waitqueue and
> helpers were used to allow the task performing rmdir to wait for the
> next relevant event.
> 
> Unfortunately, the wait is visible to controllers too and the
> mechanism got exposed to memcg by 887032670d ("cgroup avoid permanent
> sleep at rmdir").
> 
> Now that the draining and retries are gone, CGRP_WAIT_ON_RMDIR is
> unnecessary.  Remove it and all the mechanisms supporting it.  Note
> that memcontrol.c changes are essentially revert of 887032670d
> ("cgroup avoid permanent sleep at rmdir").
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reviewed-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

plz forget my comments on v1...But...

If swap-in makes a charge before css is deactivated, pre_destroy()->force_empty()
will cause infinite loop until it finds a newly charged page in LRU. I think
force_empty() will find it by lru_drain() and can make res_coutnter to be 0.

I think we need some test with swap-in handling..Anyway, 

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
