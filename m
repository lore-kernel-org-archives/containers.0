From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/2] Resource usage threshold notification addition to
	res_counter (v3)
Date: Tue, 14 Jul 2009 10:45:43 +0900
Message-ID: <20090714104543.c7e7fe32.kamezawa.hiroyu__39389.5931345925$1247536098$gmane$org@jp.fujitsu.com>
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	<1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
	<1247530581-31416-2-git-send-email-vbuzov@embeddedalley.com>
	<20090714093022.6e8c1cc0.kamezawa.hiroyu@jp.fujitsu.com>
	<4A5BDF5D.8090306@embeddedalley.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A5BDF5D.8090306-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Vladislav D. Buzov" <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Cc: Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, memory management list <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 13 Jul 2009 18:29:01 -0700
"Vladislav D. Buzov" <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Mon, 13 Jul 2009 17:16:20 -0700
> > Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org> wrote:
> >
> >   
> >> This patch updates the Resource Counter to add a configurable resource usage
> >> threshold notification mechanism.
> >>
> >> Signed-off-by: Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
> >> Signed-off-by: Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
> >> ---
> >>  Documentation/cgroups/resource_counter.txt |   21 ++++++++-
> >>  include/linux/res_counter.h                |   69 ++++++++++++++++++++++++++++
> >>  kernel/res_counter.c                       |    7 +++
> >>  3 files changed, 95 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
> >> index 95b24d7..1369dff 100644
> >> --- a/Documentation/cgroups/resource_counter.txt
> >> +++ b/Documentation/cgroups/resource_counter.txt
> >> @@ -39,7 +39,20 @@ to work with it.
> >>   	The failcnt stands for "failures counter". This is the number of
> >>  	resource allocation attempts that failed.
> >>  
> >> - c. spinlock_t lock
> >> + e. unsigned long long threshold
> >> +
> >> + 	The resource usage threshold to notify the resouce controller. This is
> >> +	the minimal difference between the resource limit and current usage
> >> +	to fire a notification.
> >> +
> >> + f. void (*threshold_notifier)(struct res_counter *counter)
> >> +
> >> +	The threshold notification callback installed by the resource
> >> +	controller. Called when the usage reaches or exceeds the threshold.
> >> +	Should be fast and not sleep because called when interrupts are
> >> +	disabled.
> >> +
> >>     
> >
> > This interface isn't very useful..hard to use..can't you just return the result as
> > "exceeds threshold" to the callers ?
> >
> > If I was you, I'll add following state to res_counter
> >
> > enum {
> > 	RES_BELOW_THRESH,
> > 	RES_OVER_THRESH,
> > } res_state;
> >
> > struct res_counter {
> > 	.....
> > 	enum	res_state	state;
> > }
> >
> > Then, caller does
> > example)
> > 	prev_state = res->state;
> > 	res_counter_charge(res....)
> > 	if (prev_state != res->state)
> > 		do_xxxxx..
> >
> > notifier under spinlock is not usual interface. And if this is "notifier",
> > something generic, notifier_call_chain should be used rather than original
> > one, IIUC.
> >
> > So, avoiding to use "callback" is a way to go, I think.
> >
> >   
> The reason of having this callback is to support the hierarchy, which
> was the problem in previous implementation you pointed out.
> 
> When a new page charged we want to walk up the hierarchy and find all
> the ancestors exceeding their thresholds and notify them. To avoid
> walking up the hierarchy twice, I've expanded res_counter with "notifier
> callback" called by res_counter_charge() for each res_counter in the
> tree which exceeds the limit.
> 
> In the example above, the hierarchy is not supported. We know only state
> of the res_counter/memcg which current thread belongs to.
> 
How heavy res_coutner can be ? ;) plz don't check at "every charge", use some
filter.

plz discuss with Balbir. His softlimit adds something similar. And I don't think
both are elegant.

I'll consider more (of course, I may not be able to find any..) and rewrite the
whole thing if I have a chance.

Briefly thinking, it's not very bad to have following interface.

==
/*
 * This function is for checking all ancestors's state. Each ancestors are
 * pased to check_function() ony be one until res->parent is not NULL.
 */
void res_counter_callback(struct res_counter *res, int (*check_function)())
{
	do {
		if ((*check_function)(res))
			break;
		res = res->parent;
	} while (res);
}
==
Calling this once per 1000 charges or once per sec will not be very bad. And we can
keep res_counter simple. If you want some trigger, you can add something as
you like.

Thanks,
-Kame
