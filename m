From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 5/6] memcg: fix broken boolen expression
Date: Wed, 4 Apr 2012 14:34:03 -0700
Message-ID: <20120404143403.fd05a284.akpm@linux-foundation.org>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
	<1324695619-5537-5-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1324695619-5537-5-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 24 Dec 2011 05:00:18 +0200
"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> 
> action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> 
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b27ce0f..3833a7b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2100,7 +2100,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  		return NOTIFY_OK;
>  	}
>  
> -	if ((action != CPU_DEAD) || action != CPU_DEAD_FROZEN)
> +	if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
>  		return NOTIFY_OK;
>  
>  	for_each_mem_cgroup(iter)

This spent too long in the backlog, sorry.

I don't want to merge this patch into either mainline or -stable until
I find out what it does!

afacit the patch will newly cause the kernel to drain various resource
counters away from the target CPU when the CPU_DEAD or CPU_DEAD_FROZEN
events occur for thet CPU, yes?

So the user-visible effects of the bug whcih was just fixed is that
these counters will be somewhat inaccurate after a CPU is taken down,
yes?

Why wasn't this bug noticed before?  Has anyone tested the patch and
confirmed that the numbers are now correct?

Given that this bug has been present for 1.5 years and nobody noticed,
I don't think a backport into -stable is warranted?
