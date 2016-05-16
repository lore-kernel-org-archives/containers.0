From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH RFC 0/3] sched/fair: cpu time reserves for cgroups
Date: Mon, 16 May 2016 13:18:49 +0200
Message-ID: <20160516111849.GN3193__13702.3513358601$1463398868$gmane$org@twins.programming.kicks-ass.net>
References: <146339085068.25295.7687045977863852568.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <146339085068.25295.7687045977863852568.stgit@buzz>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 16, 2016 at 12:36:19PM +0300, Konstantin Khlebnikov wrote:
> This feature allows to change cpu cgroup weight for a limited time.
> 
> Cgroup interface:
> cpu.cfs_reserve_us      - reserved time for each cpu.cfs_period_us
> cpu.cfs_reserve_shares  - group weight during reserved time
> 
> While cfs group consumes reserved cpu time it has different weight,
> thus it gets different vruntime penalty for that execution.
> 
>         ^ weight
>         |
>         |
> reserve |
> shares  -------*
>         |      |
>         |      |
>         |      |
> shares  -      *-----------------*
>         |                        |
>         |                        |
>         0------|-----------------|-----------> time
>                reserve           quota
> 
> Reserve can work as a "low limit": boost weight for "guaranteed" time,
> and as a "high limit": give normal weight for a limited time and allow
> utilize cpu when nobody else needs it.
> 

You forgot to explain why I should care about this.
