From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Mon, 22 Feb 2010 18:57:29 +0100
Message-ID: <20100222175728.GA4052__296.628385740583$1266861582$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
	<20100222093221.eaaff1b4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100222093221.eaaff1b4.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 22, 2010 at 09:32:21AM +0900, KAMEZAWA Hiroyuki wrote:
> > -	if (vm_dirty_bytes)
> > -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> > +	dirty_bytes = mem_cgroup_dirty_bytes();
> > +	if (dirty_bytes)
> > +		dirty = DIV_ROUND_UP(dirty_bytes, PAGE_SIZE);
> >  	else {
> >  		int dirty_ratio;
> 
> you use local value. But, if hierarchila accounting used, memcg->dirty_bytes
> should be got from root-of-hierarchy memcg.
> 
> I have no objection if you add a pointer as
> 	memcg->subhierarchy_root
> to get root of hierarchical accounting. But please check problem of hierarchy, again.

Right, it won't work with hierarchy. I'll fix also considering the
hierarchy case.

Thanks for your review.

-Andrea
