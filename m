From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Tue, 23 Feb 2010 10:58:25 +0100
Message-ID: <20100223095825.GG1882__28797.7023319856$1266919234$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
	<20100222092242.98df82e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100222193113.GE3096@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100222193113.GE3096-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Mon, Feb 22, 2010 at 02:31:13PM -0500, Vivek Goyal wrote:
> On Mon, Feb 22, 2010 at 09:22:42AM +0900, KAMEZAWA Hiroyuki wrote:
> 
> [..]
> > > +static int mem_cgroup_dirty_bytes_write(struct cgroup *cgrp, struct cftype *cft,
> > > +				       u64 val)
> > > +{
> > > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > > +	struct mem_cgroup *parent;
> > > +
> > > +	if (cgrp->parent == NULL)
> > > +		return -EINVAL;
> > > +
> > > +	parent = mem_cgroup_from_cont(cgrp->parent);
> > > +
> > > +	cgroup_lock();
> > > +
> > > +	/* If under hierarchy, only empty-root can set this value */
> > > +	if ((parent->use_hierarchy) ||
> > > +	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> > > +		cgroup_unlock();
> > > +		return -EINVAL;
> > > +	}
> > 
> > Okay, then, only hierarchy root can set the value.
> > Please descirbe this kind of important things in patch description.
> > 
> 
> Hi Andrea,
> 
> Why can only root of the hierarchy set set dirty_bytes value? In this
> case, a child cgroup's amount of dirty pages will be controlled by
> dirty_ratio?

I'm rewriting the patch to correctly handle hierarchy. The hierarchy
design is completely broken in this patch.

-Andrea
