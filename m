From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Q: cgroup: Questions about possible issues in cgroup locking
Date: Wed, 1 Feb 2012 17:28:55 +0100
Message-ID: <20120201162851.GD6731__13246.076872065$1328113752$gmane$org@somewhere.redhat.com>
References: <20111221034334.GD17668@somewhere>
	<20111221130848.GA19679@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111221130848.GA19679-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Dec 21, 2011 at 02:08:48PM +0100, Oleg Nesterov wrote:
> On 12/21, Frederic Weisbecker wrote:
> > - Is the check for use_task_css_set_links in cgroup_post_fork() safe? given
> > it is checked outside css_set_lock?
> >
> > Imagine this:
> >
> > CPU 0                                                        CPU 1
> > ----                                                         -----
> >
> > cgroup_enable_task_cg() {
> > 	uset_tasks_css_set_links = 1
> > 	for_each_thread() {
> > 		add tasks in the list
> > 	}
> > }
> >                                                            do_fork() {
> >                                                                cgroup_post_fork() {
> >                                                                      use_tasks_css_set_links appears
> >                                                                      to be equal to 0 due to write/read
> >                                                                       not flushed. New task won't
> >                                                                       appear to the list.
> 
> Yes, I was thinking about this too.
> 
> Or (I think) they can race "contrariwise". CPU_1 creates the new child,
> then CPU_0 sets uset_tasks_css_set_links = 1. But afaics there is no any
> guarantee that CPU_0 sees the result of list_add_tail_rcu().

Exactly! In fact even if RCU was safe with while_each_thread() it wouldn't
be enough for us because of that.

I fear we need the read_lock(tasklist_lock) here, with a pair of smp
barriers to ensure use_task_css_set_links update is visible as
expected.

I'll try to cook something.
