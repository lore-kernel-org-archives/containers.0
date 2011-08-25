From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Thu, 25 Aug 2011 17:21:40 +0900
Message-ID: <20110825172140.eb34809f.kamezawa.hiroyu__23969.2760784694$1314261082$gmane$org@jp.fujitsu.com>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-4-git-send-email-tj@kernel.org>
	<20110825093958.75b95bd8.kamezawa.hiroyu@jp.fujitsu.com>
	<20110825082049.GC3286@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110825082049.GC3286-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 25 Aug 2011 10:20:49 +0200
Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> Hello, KAMEZAWA.
> 

> > > @@ -5460,8 +5460,9 @@ static void mem_cgroup_clear_mc(void)
> > >  
> > >  static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> > >  				struct cgroup *cgroup,
> > > -				struct task_struct *p)
> > > +				struct cgroup_taskset *tset)
> > >  {
> > > +	struct task_struct *p = cgroup_taskset_first(tset);
> > >  	int ret = 0;
> > >  	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
> > >  
> > 
> > Ah..hmm. I think this doesn't work as expected for memcg.
> > Maybe code like this will be required.
> 
> Hmmm... the above is basically identity transformation of the existing
> code.  If the above is broken, the current code is broken too.  Is it?
> 
Current code is not broken.

mem_cgroup_can_attach(....., task) need to do real job only when task->mm->owner
== task. In this modification, you pass a set of task at once.
So, mem_cgroup_can_attach() need to check _all_ tasks in tset rather than a
first task in tset. please scan and find mm->owner.

Anyway, if you merge this onto mm-tree first, I think I can have time to
write a fix up if complicated.

Thanks,
-Kame
