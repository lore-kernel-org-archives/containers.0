From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 4/4] memcg: dirty pages instrumentation
Date: Thu, 4 Mar 2010 22:51:01 +0100
Message-ID: <20100304215101.GB4787@linux>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	<1267699215-4101-5-git-send-email-arighi@develer.com>
	<20100304194144.GE18786@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100304194144.GE18786-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 04, 2010 at 02:41:44PM -0500, Vivek Goyal wrote:
> On Thu, Mar 04, 2010 at 11:40:15AM +0100, Andrea Righi wrote:
> 
> [..]
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 5a0f8f3..c5d14ea 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -137,13 +137,16 @@ static struct prop_descriptor vm_dirties;
> >   */
> >  static int calc_period_shift(void)
> >  {
> > +	struct dirty_param dirty_param;
> >  	unsigned long dirty_total;
> >  
> > -	if (vm_dirty_bytes)
> > -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> > +	get_dirty_param(&dirty_param);
> > +
> > +	if (dirty_param.dirty_bytes)
> > +		dirty_total = dirty_param.dirty_bytes / PAGE_SIZE;
> >  	else
> > -		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> > -				100;
> > +		dirty_total = (dirty_param.dirty_ratio *
> > +				determine_dirtyable_memory()) / 100;
> >  	return 2 + ilog2(dirty_total - 1);
> >  }
> >  
> 
> Hmm.., I have been staring at this for some time and I think something is
> wrong. I don't fully understand the way floating proportions are working
> but this function seems to be calculating the period over which we need
> to measuer the proportions. (vm_completion proportion and vm_dirties
> proportions).
> 
> And we this period (shift), when admin updates dirty_ratio or dirty_bytes
> etc. In that case we recalculate the global dirty limit and take log2 and
> use that as period over which we monitor and calculate proportions.
> 
> If yes, then it should be global and not per cgroup (because all our 
> accouting of bdi completion is global and not per cgroup).
> 
> PeterZ, can tell us more about it. I am just raising the flag here to be
> sure.
> 
> Thanks
> Vivek

Hi Vivek,

I tend to agree, we must use global dirty values here.

BTW, update_completion_period() is called from dirty_* handlers, so it's
totally unrelated to use the current memcg. That's the memcg where the
admin is running, so probably it's the root memcg almost all the time,
but it's wrong in principle. In conclusion this patch shouldn't touch
calc_period_shift().

Thanks,
-Andrea
