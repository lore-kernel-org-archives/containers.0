From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/2] scheduler: cgroups cpuaccouting: Make cpuusage atomic
Date: Thu, 20 May 2010 09:43:11 +0900
Message-ID: <20100520094311.999d3d92.kamezawa.hiroyu__43691.5971957662$1274316502$gmane$org@jp.fujitsu.com>
References: <1274264877.5605.10541.camel@twins>
	<1274295539-7798-3-git-send-email-trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274295539-7798-3-git-send-email-trenn-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 19 May 2010 20:58:59 +0200
Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org> wrote:

> and avoid locking on 32 bit.
> This resolves an ugly dependency in cgroups_cpuaccount.c
> to per_cpu runqueues lock variable.
> 
> Signed-off-by: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
> CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org
> CC: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
> CC: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
> CC: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> CC: mingo-X9Un+BFzKDI@public.gmane.org
> CC: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
> ---
>  kernel/cgroup_cpuaccount.c |   39 +++++++++------------------------------
>  kernel/sched.c             |   11 -----------
>  kernel/sched.h             |    7 -------
>  3 files changed, 9 insertions(+), 48 deletions(-)
>  delete mode 100644 kernel/sched.h
> 
> diff --git a/kernel/cgroup_cpuaccount.c b/kernel/cgroup_cpuaccount.c
> index 0ad356a..0a53487 100644
> --- a/kernel/cgroup_cpuaccount.c
> +++ b/kernel/cgroup_cpuaccount.c
> @@ -10,8 +10,6 @@
>  
>  #include <asm/cputime.h>
>  
> -#include "sched.h"
> -
>  /*
>   * CPU accounting code for task groups.
>   *
> @@ -23,7 +21,7 @@
>  struct cpuacct {
>  	struct cgroup_subsys_state css;
>  	/* cpuusage holds pointer to a u64-type object on every cpu */
> -	u64 __percpu *cpuusage;
> +	atomic64_t __percpu *cpuusage;

Hmmm...how about adding seq_counter for 32bit rather than atomic64_t ?

Thanks,
-Kame
