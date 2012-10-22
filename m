From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroup: cgroup_subsys->fork() should be called
	after the task is added to css_set
Date: Mon, 22 Oct 2012 20:04:45 +0200
Message-ID: <20121022180445.GB21553@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-2-git-send-email-tj@kernel.org>
	<20121021191141.GA26218@redhat.com>
	<20121021192222.GB5951@atj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121021192222.GB5951-OlzNCW9NnSVy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Tejun,

On 10/21, Tejun Heo wrote:
>
> On Sun, Oct 21, 2012 at 09:11:41PM +0200, Oleg Nesterov wrote:
>
> > And it seems that fork() can race with cgroup iterator. post_fork
> > will notice use_task_css_set_links, but until then the child belongs
> > to the parent's css and it is not "visible" to iterator (and right
> > after cgroup_fork() it is not visible to do_each_thread() if
> > use_task_css_set_links is not set).
> >
> > For example. Suppose that the child migrates to another cgroup after
> > copy_process() makes it visible to the user-space. Then update_if_frozen
> > sets CGROUP_FROZEN (again, cgroup_iter_next do not see this child).
> >
> > Now, post_fork calls freezer_fork() and hits BUG_ON(CGROUP_FROZEN).
> >
> > But again, I do not blame this patch.
>
> I'm planning to update it to,
>
> * Clear ->cgroup to %NULL during copy_process().

I completely agree. new_child->cgroups copied from parent looks simply
strange until post_fork. If nothing else, the new task is still under
construction by the time cgroup_fork() is called.

> > I am starting to think again about a big-rw-lock around copy_process.
> > Recently I tried to add one around dup_mmap for uprobes, but perhaps
> > cgroups can use it too...
>
> If some other subsystems need it, maybe just make threadgroup locking
> coarser?

What do you mean?

> I *think* I can make cgroup work correctly without a agiant
> rwlock

Yes, probably cgroup doesn't really need it. Although we could probably
kill signal->group_rwsem, but this is minor and "write-lock" will be much
slower.

Oleg.
