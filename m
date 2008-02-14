From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] memory controller : backgorund reclaim and avoid
	excessive locking [3/5] throttling
Date: Thu, 14 Feb 2008 18:38:56 +0900
Message-ID: <20080214183856.0ffd99db.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080214172148.bfd564d5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080214173043.d57b3619.kamezawa.hiroyu@jp.fujitsu.com>
	<47B4068A.2050104@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47B4068A.2050104-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 14 Feb 2008 14:44:50 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > By this interface, a user can control the # of threads which can enter
> > try_to_free...
> > 
> 
> What happens to the other threads, do they sleep?
> 
yes.

> > Default is 10240 ...a enough big number for unlimited. Maybe this should
> > be changed.
> > 
> > 
> > Changes from previous one.
> >   - Added an interface to control the limit.
> >   - don't call wake_up at uncharge()...it seems hevay..
> >     Instead of that, sleepers use schedule_timeout(HZ/100). (10ms)
> > 
> > Considerations:
> >   - Should we add this 'throttle' to global_lru at first ?
> 
> Hmm.. interesting question. I think Rik is looking into some of these issues
> 
Maybe. I thought someone posted a patch to -mm but I lost the mail.


> > +	 * throttling params for reclaim.
> > +	 */
> > +	struct {
> > +		int		limit;
> 
> We might want to use something else instead of limit. How about
> max_parallel_reclaimers?
> 
ok.


> > +		prepare_to_wait(&mem->throttle.waitq, &wait,
> > +						TASK_INTERRUPTIBLE);
> > +		if (res_counter_check_under_limit(&mem->res)) {
> > +			finish_wait(&mem->throttle.waitq, &wait);
> > +			break;
> > +		}
> > +		/* expect some progress in... */
> > +		schedule_timeout(HZ/50);
> 
> Can't we wait on someone to wake us up? Why do we need to do a schedule_timeout?

A method "Someone wakes up" adds new code to uncharge. 

 - check value and limt.
 - check waiters
 - wakes them up if any (and touches other cpu's runq->lock.)

Not very light-weight ops. just polling works well in this case, I think.

> And why HZ/50 and not HZ/10? Too many timers distract the system from power
> management :)
ok, HZ/10. (or add some knob.)



> > -		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> > +		if (((gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO))
> > +		    || mem_cgroup_throttle_reclaim(mem)) {
> 
> I think we should split this check and add detailed comments. If we cannot
> sleep, then we cannot be throttled, right?
> 
ok.

> > +	init_waitqueue_head(&mem->throttle.waitq);
> > +	mem->throttle.limit = 10240; /* maybe enough big for no throttle */
> 
> Why 10240? So, 10,000 threads can run in parallel, isn't that an overkill?

yes, it's overkill. Because I don't want to define *unlimted* value,
I used a big number.

> How about setting it to number of cpus/2 or something like that?

Hmm, in previous version, cpus/4 was used as default.
some value like cpus/2, nodes/2, seems good. (maybe).

A concern is that memory cgroup can be used with cpuset or
some other controllers. So, the best number can be various under environments.

It's one of choice we set the value as unlimited and makes user set suitable by hand.

Thanks,
-Kame
