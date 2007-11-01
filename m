From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] memory cgroup enhancements take 4 [5/8] add status
 accounting function for memory cgroup
Date: Thu, 1 Nov 2007 09:29:56 +0900
Message-ID: <20071101092956.489798fb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
	<20071031193046.a58f2ef0.kamezawa.hiroyu@jp.fujitsu.com>
	<20071031151234.4fcb42b2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071031151234.4fcb42b2.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

At first, thank you for review.

On Wed, 31 Oct 2007 15:12:34 -0700
Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > +static inline void __mem_cgroup_stat_add(struct mem_cgroup_stat *stat,
> > +                enum mem_cgroup_stat_index idx, int val)
> > +{
> > +	int cpu = smp_processor_id();
> > +	preempt_disable();
> > +	stat->cpustat[cpu].count[idx] += val;
> > +	preempt_enable();
> > +}
> 
> This is clearly doing smp_processor_id() in preemptible code.  (or the
> preempt_disable() just isn't needed).  I fixed it up.
> 
Thanks,
> Please ensure that you test with all runtime debugging options enabled -
> you should have seen a warning here.
> 
Sorry, I'll take care.


> > +/*
> > + * For accounting under irq disable, no need for increment preempt count.
> > + */
> > +static inline void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat *stat,
> > +		enum mem_cgroup_stat_index idx, int val)
> > +{
> > +	int cpu = smp_processor_id();
> > +	stat->cpustat[cpu].count[idx] += val;
> > +}
> 
> There's a wild amount of inlining in that file.  Please, just don't do it -
> inline is a highly specialised thing and is rarely needed.
> 
> When I removed the obviously-wrong inline statements, the size of
> mm/memcontrol.o went from 3823 bytes down to 3495.
> 
> It also caused this:
> 
> mm/memcontrol.c:65: warning: '__mem_cgroup_stat_add' defined but not used
> 
> so I guess I'll just remove that.
> 
ok. I'll add again if it is needed again.

Thanks,
-Kame
