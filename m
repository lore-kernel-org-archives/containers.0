From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][ just for review] memory controller enhancements [4/5]
 statistics for memory cgroup
Date: Tue, 16 Oct 2007 12:03:11 +0900
Message-ID: <20071016120311.b1f8bb7d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071015154603.050d43f6.kamezawa.hiroyu@jp.fujitsu.com>
	<20071015223823.573411BF4D9@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071015223823.573411BF4D9-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 16 Oct 2007 07:38:23 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> > > > +/*
> > > > + * For batching....mem_cgroup_charge_statistics()(see below).
> > > > + */
> > > > +static inline void mem_cgroup_stat_add(struct mem_cgroup_stat *stat,
> > > > +                enum mem_cgroup_stat_index idx, int val)
> > > > +{
> > > > +	int cpu = smp_processor_id();
> > > > +	stat->cpustat[cpu].count[idx] += val;
> > > > +}
> > > 
> > > i think the function name should be something which implies batching.
> > > 
> > Hm, How about this ?
> > ==
> > mem_cgroup_stat_add_atomic() 
> > ==
> > and add this 
> > ==
> > VM_BUG_ON(preempt_count() == 0)
> > ==
> 
> _atomic sounds like a different thing to me.  _nonpreemptible?
> 
Hmm, ok.

Thanks,
-Kame
