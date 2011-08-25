From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Thu, 25 Aug 2011 10:20:49 +0200
Message-ID: <20110825082049.GC3286__28130.7629928508$1314260543$gmane$org@htj.dyndns.org>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-4-git-send-email-tj@kernel.org>
	<20110825093958.75b95bd8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110825093958.75b95bd8.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, KAMEZAWA.

On Thu, Aug 25, 2011 at 09:39:58AM +0900, KAMEZAWA Hiroyuki wrote:
> > +Called prior to moving one or more tasks into a cgroup; if the
> > +subsystem returns an error, this will abort the attach operation.
> > +@tset contains the tasks to be attached and is guaranteed to have at
> > +least one task in it. If there are multiple, it's guaranteed that all
> > +are from the same thread group,
> 
> 
> Do this, "If there are multiple, it's guaranteed that all
> are from the same thread group ", means the 'tset' contains
> only one mm_struct ?

Yes, CLONE_THREAD requires CLONE_SIGHAND which in turn requires
CLONE_VM, so they'll all have the same mm.

> And is it guaranteed that any task in tset will not be freed while
> subsystem routine runs ?

Yeap, that one is guaranteed.  It might die but the the task_struct
itself won't be released.  However, I think it might be bette to block
task exits during migration too.

> > @@ -5460,8 +5460,9 @@ static void mem_cgroup_clear_mc(void)
> >  
> >  static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> >  				struct cgroup *cgroup,
> > -				struct task_struct *p)
> > +				struct cgroup_taskset *tset)
> >  {
> > +	struct task_struct *p = cgroup_taskset_first(tset);
> >  	int ret = 0;
> >  	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
> >  
> 
> Ah..hmm. I think this doesn't work as expected for memcg.
> Maybe code like this will be required.

Hmmm... the above is basically identity transformation of the existing
code.  If the above is broken, the current code is broken too.  Is it?

Thanks.

-- 
tejun
