From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv4] procfs: show hierarchy of pid namespace
Date: Thu, 9 Oct 2014 23:34:14 +0200
Message-ID: <20141009213414.GA10705@redhat.com>
References: <1412762198-21825-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20141008151328.GB4835@redhat.com>
	<5871495633F38949900D2BF2DC04883E5E1649@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5871495633F38949900D2BF2DC04883E5E1649-ZEd+hNNJ6a5ZYpXjqAkB5jz3u5zwRJJDAzI0kPv9QBlmR6Xm/wNWPw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/09, Chen, Hanxiao wrote:
>
> > From: Oleg Nesterov [mailto:oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
> >
> > Hmm. We only want the tasks from our namespace, yes? Perhaps find_ge_pid()
> > makes more sense?
>
> Only tasks from our ns is valid.
> But how could find_ge_pid() do that?
>
> nr = 1;
> while (nr < PID_MAX_LIMIT) {
> 	find_ge_pid(nr, curr_ns);
> 	list_add();
> 	nr++;
> }

something like this, except list_add() should obviously depend on
is_child_reaper() check.

This can be more optimal in sub-namespaces, you do not need to abuse
the global process list.

And if you change this code to use get_pid/put_pid, then you do not
need to hold rcu_read_lock() throughout, you only need it around
find_ge_pid + get_pid.

At the same time, for_each_process() in the global namespace can be
faster if there are a lot of sub-threads.

> Perhaps that's not a good way.

OK, I won't insist.

although it would be nice to know why do you think this is bad.

> > > +		pid = task_pid(p);
> >
> > Well, in theory you need barrier() here. Or perhaps we should add
> > ACCESS_ONCE() into task_pid()...
>
> You mean modify task_pid as:
> return ACCESS_ONCE(task->pids[PIDTYPE_PID].pid;);

Yes. But not now an not in this patch of course. I'd suggest to add
barrier() just in case.


> > And imho it would be better to declare pidns_list/pidns_tree locally
> > in nslist_proc_show() and pass them to the callees.
>
> That's a good idea.
> Will changed in the next version.

Good. And I forgot to mention, in this case you do not need pidns_list_lock
at all afaics.

Oleg.
