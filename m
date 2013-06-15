From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 11/11] cgroup: use percpu refcnt for cgroup_subsys_states
Date: Fri, 14 Jun 2013 23:31:55 -0700
Message-ID: <20130615063155.GC7017@htj.dyndns.org>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
	<1371096298-24402-12-git-send-email-tj@kernel.org>
	<20130614132026.GD10084@dhcp22.suse.cz>
	<20130614223125.GD6593@mtj.dyndns.org>
	<20130615053522.GA7017@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130615053522.GA7017-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 14, 2013 at 10:35:22PM -0700, Tejun Heo wrote:
> On Fri, Jun 14, 2013 at 03:31:25PM -0700, Tejun Heo wrote:
> > I'll play with it a bit more on an actual machine and post more
> > results.  Test program attached.
> 
> So, here are the results from the same test on a dual-socket 2-way
> NUMA opteron 8 core machine.
> 
> Running on one CPU.
> 
>   copy size	atomic		percpu		diff in pct
>   0		535964443	616756827	+15.07%
>   32		399988186	378678713	 -5.33%
>   64		389067476	355073979	 -8.74%
>   128		342192631	315615300	 -7.77%
>   256		281208005	260598931	 -7.33%
>   512		188070912	193225269	 +2.74%
> 
> Running on all eight cores.
> 
>   copy size	atomic		percpu		diff in pct
>   0		121324328	4889425511	+3,930.05%
>   32		 96170193	2999613380	+3,019.07%
>   64		 98139061	2813894184	+2,767.25%
>   128		112610025	2503229487	+2,122.92%
>   256		 96828114	2069865752	+2,037.67%
>   512		 95858297	1537726109	+1,504.17%
> 
> Ration of all cores / single core.
> 
>   copy size	atomic		percpu
>   0		0.23		7.93
>   32		0.24		7.92
>   64		0.25		7.92
>   128		0.33		7.93
>   256		0.34		7.94
>   512		0.51		7.96

I was testing with CONFIG_PREEMPT, which makes rcu_read_[un]lock()s
quite a bit more expensive.  The following is the same test results
with CONFIG_PREEMPT_VOLUNTARY which would the most preemptive server
distros would get anyway.

One CPU.

  copy size	atomic		percpu		diff in pct
  0		534583387	1521561724	+184.63%
  32		399098138	 615962137	+ 54.34%
  64		388128431	 555599274	+ 43.15%
  128		341336474	 464502792	+ 36.08%
  256		280471681	 354186740	+ 26.28%
  512		203784802	 240067596	+ 17.80%

All eight CPUs.

  copy size	atomic		percpu		diff in pct
  0		117213982	12488998111	+10,554.87%
  32		103545751	4940695158	+ 4,671.51%
  64		 98135094	4456370409	+ 4,441.06%
  128		117729659	3725434154	+ 3,064.40%
  256		 95916768	2840992396	+ 2,861.94%
  512		 95795993	1926044518	+ 1,910.57%

Ration of all cores / single core.

  copy size	atomic		percpu
  0		0.22		8.21
  32		0.26		8.02
  64		0.25		8.02
  128		0.34		8.02
  256		0.34		8.02
  512		0.47		8.02	

So, it's faster even with only one CPU.

Thanks.

-- 
tejun
