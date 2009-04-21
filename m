From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/7] res_counter: introduce ratelimiting attributes
Date: Tue, 21 Apr 2009 11:55:26 +0200
Message-ID: <20090421095525.GA13699__44017.6797019832$1240308000$gmane$org@linux>
References: <1240090712-1058-1-git-send-email-righi.andrea@gmail.com>
	<1240090712-1058-3-git-send-email-righi.andrea@gmail.com>
	<20090421091534.971f676f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090421091534.971f676f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 21, 2009 at 09:15:34AM +0900, KAMEZAWA Hiroyuki wrote:
> On Sat, 18 Apr 2009 23:38:27 +0200
> Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > Introduce attributes and functions in res_counter to implement throttling-based
> > cgroup subsystems.
> > 
> > The following attributes have been added to struct res_counter:
> >  * @policy:     the limiting policy / algorithm
> >  * @capacity:   the maximum capacity of the resource
> >  * @timestamp:  timestamp of the last accounted resource request
> > 
> > Currently the available policies are: token-bucket and leaky-bucket and the
> > attribute @capacity is only used by token-bucket policy (to represent the
> > bucket size).
> > 
> > The following function has been implemented to return the amount of time a
> > cgroup should sleep to remain within the defined resource limits.
> > 
> >   unsigned long long
> >   res_counter_ratelimit_sleep(struct res_counter *res, ssize_t val);
> > 
> > [ Note: only the interfaces needed by the cgroup IO controller are implemented
> > right now ]
> > 
> > Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  include/linux/res_counter.h |   69 +++++++++++++++++++++++++++++++----------
> >  kernel/res_counter.c        |   72 +++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 124 insertions(+), 17 deletions(-)
> > 
> > diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> > index 4c5bcf6..9bed6af 100644
> > --- a/include/linux/res_counter.h
> > +++ b/include/linux/res_counter.h
> > @@ -14,30 +14,36 @@
> >   */
> >  
> >  #include <linux/cgroup.h>
> > +#include <linux/jiffies.h>
> >  
> > -/*
> > - * The core object. the cgroup that wishes to account for some
> > - * resource may include this counter into its structures and use
> > - * the helpers described beyond
> > - */
> > +/* The various policies that can be used for ratelimiting resources */
> > +#define	RATELIMIT_LEAKY_BUCKET	0
> > +#define	RATELIMIT_TOKEN_BUCKET	1
> >  
> > +/**
> > + * struct res_counter - the core object to account cgroup resources
> > + *
> > + * @usage:	the current resource consumption level
> > + * @max_usage:	the maximal value of the usage from the counter creation
> > + * @limit:	the limit that usage cannot be exceeded
> > + * @failcnt:	the number of unsuccessful attempts to consume the resource
> > + * @policy:	the limiting policy / algorithm
> > + * @capacity:	the maximum capacity of the resource
> > + * @timestamp:	timestamp of the last accounted resource request
> > + * @lock:	the lock to protect all of the above.
> > + *		The routines below consider this to be IRQ-safe
> > + *
> > + * The cgroup that wishes to account for some resource may include this counter
> > + * into its structures and use the helpers described beyond.
> > + */
> >  struct res_counter {
> > -	/*
> > -	 * the current resource consumption level
> > -	 */
> >  	unsigned long long usage;
> > -	/*
> > -	 * the maximal value of the usage from the counter creation
> > -	 */
> >  	unsigned long long max_usage;
> > -	/*
> > -	 * the limit that usage cannot exceed
> > -	 */
> >  	unsigned long long limit;
> > -	/*
> > -	 * the number of unsuccessful attempts to consume the resource
> > -	 */
> >  	unsigned long long failcnt;
> > +	unsigned long long policy;
> > +	unsigned long long capacity;
> > +	unsigned long long timestamp;
> >  
> Andrea, sizeof(struct res_counter) is getting close to 128bytes. (maybe someone adds more)
> Then, could you check "unsigned long or unsigned int" is allowed or not, again ?
> 
> It's very bad if cacheline of spinlock is different from data field, in future.

Regarding the new attributes, policy can be surely an unsigned int or
even less (now only 1 bit is used!), maybe we can just add an unsigned
int flags, and encode also potential future informations there.

Moreover, are we sure we really need an unsigned long long for failcnt?

Thanks,
-Andrea
