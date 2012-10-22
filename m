From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroup: cgroup_subsys->fork() should be called after
	the task is added to css_set
Date: Mon, 22 Oct 2012 17:16:31 -0400
Message-ID: <20121022211631.GE5951@atj.dyndns.org>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-2-git-send-email-tj@kernel.org>
	<20121021191141.GA26218@redhat.com>
	<20121021192222.GB5951@atj.dyndns.org>
	<20121022180445.GB21553@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121022180445.GB21553-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey,

On Mon, Oct 22, 2012 at 08:04:45PM +0200, Oleg Nesterov wrote:
> > * Clear ->cgroup to %NULL during copy_process().
> 
> I completely agree. new_child->cgroups copied from parent looks simply
> strange until post_fork. If nothing else, the new task is still under
> construction by the time cgroup_fork() is called.

Yeah, and it's just nasty to have cgroup->fork() and ->attach() racing
each other.  As far as cgroup is concerned, the new task should be
completely idle till ->fork() is complete.

> > > I am starting to think again about a big-rw-lock around copy_process.
> > > Recently I tried to add one around dup_mmap for uprobes, but perhaps
> > > cgroups can use it too...
> >
> > If some other subsystems need it, maybe just make threadgroup locking
> > coarser?
> 
> What do you mean?

I probabl have misunderstood you but If you're gonna add big-rw-lock
around copy-process which is always gonna be grabbed, I was suggesting
maybe we could simply repurpose the existing threadgroup locking.  Or
are the requirements too different?

Thanks.

--
tejun
