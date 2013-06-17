From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 11/11] cgroup: use percpu refcnt for cgroup_subsys_states
Date: Mon, 17 Jun 2013 15:27:44 +0200
Message-ID: <20130617132744.GB5018__3410.50195643238$1371475685$gmane$org@dhcp22.suse.cz>
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri 14-06-13 22:35:22, Tejun Heo wrote:
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
> 
> Note exactly 8 - the cores do share quite a bit of resources after all
> - but pretty close.
> 

Thanks for your results! Yes the boost can be really high. I will try to
measure some memcg workloads as soon as I have some spare cycles. I do
not expect a big win but I also do not think this would regress.

Thanks.
-- 
Michal Hocko
SUSE Labs
