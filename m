From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/2] memcg: dirty pages accounting and limiting
	infrastructure
Date: Tue, 23 Feb 2010 12:58:46 +0100
Message-ID: <20100223115846.GI1882@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-2-git-send-email-arighi@develer.com>
	<alpine.DEB.2.00.1002211321010.22858@chino.kir.corp.google.com>
	<20100221221700.GA5233@linux> <20100222180732.GC3096@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100222180732.GC3096-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 22, 2010 at 01:07:32PM -0500, Vivek Goyal wrote:
> > > > +unsigned long mem_cgroup_dirty_bytes(void)
> > > > +{
> > > > +	struct mem_cgroup *memcg;
> > > > +	unsigned long dirty_bytes;
> > > > +
> > > > +	if (mem_cgroup_disabled())
> > > > +		return vm_dirty_bytes;
> > > > +
> > > > +	rcu_read_lock();
> > > > +	memcg = mem_cgroup_from_task(current);
> > > > +	if (memcg == NULL)
> > > > +		dirty_bytes = vm_dirty_bytes;
> > > > +	else
> > > > +		dirty_bytes = get_dirty_bytes(memcg);
> > > > +	rcu_read_unlock();
> > > 
> > > The rcu_read_lock() isn't protecting anything here.
> > 
> > Right!
> 
> Are we not protecting "memcg" pointer using rcu here?

Vivek, you are right:

 mem_cgroup_from_task() -> task_subsys_state() -> rcu_dereference()

So, this *must* be RCU protected.

Thanks!
-Andrea
