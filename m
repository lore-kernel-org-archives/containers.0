From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Mon, 10 Nov 2008 02:02:49 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0811100158580.18129@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
	<20081104124753.fb1dde5a.akpm@linux-foundation.org>
	<1225831988.7803.1939.camel@twins>
	<20081104131637.68fbe055.akpm@linux-foundation.org>
	<1225833710.7803.1993.camel@twins>
	<20081104135004.f1717fcf.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041601100.5077@quilx.com>
	<20081104143534.b5c16147.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041648350.6254@quilx.com>
	<20081104153610.bbfd5ed8.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811042036000.31167@quilx.com>
	<20081104190505.769b93ec.akpm@linux-foundation.org>
	<20081105133157.db8bae72.kamezawa.hiroyu@jp.fujitsu.com>
	<4917F895.109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4917F895.109-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: npiggin-l3A5Bk7waGM@public.gmane.org, Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, dfults-sJ/iWh9BUns@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 10 Nov 2008, Andrea Righi wrote:

> > IIUC, Andrea Righ posted 2 patches around dirty_ratio. (added him to CC:)
> > in early October.
> > 
> >   (1) patch for adding dirty_ratio_pcm. (1/100000)
> >   (2) per-memcg dirty ratio. (maybe this..http://lkml.org/lkml/2008/9/12/121)
> >  
> > (1) should be just posted again.
> > 
> > Because we have changed page_cgroup implementation, (2) should be reworked.
> > "rework" itself will not be very difficult.
> > (.... we tend to be stick to "what interface is the best" discussion ;) 
> > 
> > But memcg itself is not so weak against dirty_pages because we don't call
> > try_to_free_pages() becasue of memory shortage but because of memory limitation.
> > 
> > BTW, in my current stack, followings are queued.
> >    a. handle SwapCache in proper way in memcg.
> >    b. handle swap_cgroup (if configured)
> >    c. make LRU handling easier
> > 
> > For making per-memcg dirty_ratio sane, (a) should go ahead. I do (a) now.
> > If Andrea seems to be too busy, I'll schedule dirty_ratio-for-memcg as my work.
> > 
> 
> Hi Kame,
> 
> sorry for my late. If it's not too late tonight I'll rebase and test (1)
> to 2.6.28-rc2-mm1 and start to rework on (2), also considering the
> David's suggestion (split NR_UNSTABLE_NFS from NR_FILE_DIRTY).
> 

The dirty throttling change only depends on patch 1/2 from (2) above, 
which adds the necessary statistics to the memcg for calculating dirty 
ratios.  Patch 2/2 from that series will need to be moved out to a 
separate cgroup as the general consensus from this discussion has 
indicated is necessary.

If it's possible to get a rebased patch 1/2 to add the statistics to the 
memory controller, I'll take it and move the all dirty throttling to a 
separate cgroup so it supports both cpusets and memcg.  Thanks!
