From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Mon, 22 Feb 2010 19:00:14 +0100
Message-ID: <20100222180013.GB4052__41776.1033786975$1266861874$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
	<20100222092242.98df82e4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100222092242.98df82e4.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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

On Mon, Feb 22, 2010 at 09:22:42AM +0900, KAMEZAWA Hiroyuki wrote:

[snip]

> > +static unsigned long get_dirty_bytes(struct mem_cgroup *memcg)
> > +{
> > +	struct cgroup *cgrp = memcg->css.cgroup;
> > +	unsigned long dirty_bytes;
> > +
> > +	/* root ? */
> > +	if (cgrp->parent == NULL)
> > +		return vm_dirty_bytes;
> 
> We have mem_cgroup_is_root() macro.
> 
> > +
> > +	spin_lock(&memcg->reclaim_param_lock);
> > +	dirty_bytes = memcg->dirty_bytes;
> > +	spin_unlock(&memcg->reclaim_param_lock);
> > +
> > +	return dirty_bytes;
> > +}
> Hmm...do we need spinlock ? You use "unsigned long", then, read-write
> is always atomic if not read-modify-write.

I think I simply copy&paste the memcg->swappiness case. But I agree,
read-write should be atomic.

-Andrea
