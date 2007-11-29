From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [5/5]
Date: Thu, 29 Nov 2007 10:26:09 +0900
Message-ID: <20071129102609.306dcd56.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071128174923.1f54f53f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071128175713.4e9b8fff.kamezawa.hiroyu@jp.fujitsu.com>
	<474D4BAE.7090407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <474D4BAE.7090407-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 28 Nov 2007 14:06:22 +0300
Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> > +	struct {
> > +		wait_queue_head_t waitq;
> > +		struct task_struct *thread;
> > +	} daemon;
> 
> Does this HAS to be a struct?
> 
No, but for shorter name of member.
(I'd like to add another waitq for avoiding contention in reclaiming,
 If I can.)


> > + * Background page reclaim daeom for memory controller.
> > + */
> > +
> > +static int mem_cgroup_reclaim_daemon(void *data)
> > +{
> > +	DEFINE_WAIT(wait);
> > +	struct mem_cgroup *mem = data;
> > +
> > +	css_get(&mem->css);
> 
> Won't this prevent the css from being removed?
> 
This refcnt is dropped when this thread dies.
pre_destroy handler handles this at rmdir().


> >  	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> >  	int ret;
> > +
> 
> This hunk is not needed :)
> 
yes :)

> >  	ret = mem_cgroup_force_empty(mem);
> >  	if (!ret)
> >  		ret = nbytes;
> > @@ -1188,6 +1244,16 @@
> >  
> >  static struct mem_cgroup init_mem_cgroup;
> >  
> > +static int __init mem_cgroup_reclaim_init(void)
> > +{
> > +	init_mem_cgroup.daemon.thread = kthread_run(mem_cgroup_reclaim_daemon,
> > +					&init_mem_cgroup, "memcontd");
> > +	if (IS_ERR(init_mem_cgroup.daemon.thread))
> > +		BUG();
> > +	return 0;
> > +}
> > +late_initcall(mem_cgroup_reclaim_init);
> > +
> >  static struct cgroup_subsys_state *
> >  mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  {
> > @@ -1212,6 +1278,17 @@
> >  		if (alloc_mem_cgroup_per_zone_info(mem, node))
> >  			goto free_out;
> >  
> > +	/* Memory Reclaim Daemon per cgroup */
> > +	init_waitqueue_head(&mem->daemon.waitq);
> > +	if (mem != &init_mem_cgroup) {
> > +		/* Complicated...but we cannot call kthread create here..*/
> > +		/* init call will later assign kthread */
> > +		mem->daemon.thread = kthread_run(mem_cgroup_reclaim_daemon,
> > +					mem, "memcontd");
> > +		if (IS_ERR(mem->daemon.thread))
> > +			goto free_out;
> 
> goto free_mem_cgroup_per_zone_info()?
> 
Ah.. there may be some bugs. will fix soon.

Thank you for all your comments.

Regards,
-Kame
