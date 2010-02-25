From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Thu, 25 Feb 2010 16:12:11 +0100
Message-ID: <20100225151211.GC3964__37784.2127382339$1267110807$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
	<20100223212943.GF11930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100223212943.GF11930-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 23, 2010 at 04:29:43PM -0500, Vivek Goyal wrote:
> On Sun, Feb 21, 2010 at 04:18:45PM +0100, Andrea Righi wrote:
> 
> [..]
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 0b19943..c9ff1cd 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -137,10 +137,11 @@ static struct prop_descriptor vm_dirties;
> >   */
> >  static int calc_period_shift(void)
> >  {
> > -	unsigned long dirty_total;
> > +	unsigned long dirty_total, dirty_bytes;
> >  
> > -	if (vm_dirty_bytes)
> > -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> > +	dirty_bytes = mem_cgroup_dirty_bytes();
> > +	if (dirty_bytes)
> > +		dirty_total = dirty_bytes / PAGE_SIZE;
> >  	else
> >  		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> >  				100;
> 
> Ok, I don't understand this so I better ask. Can you explain a bit how memory
> cgroup dirty ratio is going to play with per BDI dirty proportion thing.
> 
> Currently we seem to be calculating per BDI proportion (based on recently
> completed events), of system wide dirty ratio and decide whether a process
> should be throttled or not.
> 
> Because throttling decision is also based on BDI and its proportion, how
> are we going to fit it with mem cgroup? Is it going to be BDI proportion
> of dirty memory with-in memory cgroup (and not system wide)?

IMHO we need to calculate the BDI dirty threshold as a function of the
cgroup's dirty memory, and keep BDI statistics system wide.

So, if a task is generating some writes, the threshold to start itself
the writeback will be calculated as a function of the cgroup's dirty
memory. If the BDI dirty memory is greater than this threshold, the task
must start to writeback dirty pages until it reaches the expected dirty
limit.

OK, in this way a cgroup with a small dirty limit may be forced to
writeback a lot of pages dirtied by other cgroups on the same device.
But this is always related to the fact that tasks are forced to
writeback dirty inodes randomly, and not the inodes they've actually
dirtied.

-Andrea
