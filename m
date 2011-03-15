From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v8 3/3] cgroups: make procs file writable
Date: Tue, 15 Mar 2011 17:13:53 -0400
Message-ID: <20110315211353.GA9992@ghc17.ghc.andrew.cmu.edu>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013950.GF31569@ghc17.ghc.andrew.cmu.edu>
	<AANLkTinEnNsu8=PEktXL_EECzGYqsgdf+uogGxe7k4W+@mail.gmail.com>
	<20110310061831.GA23736@ghc17.ghc.andrew.cmu.edu>
	<AANLkTikkmfwk0nV0p=omz2ddrw+ZqWF1Lx3EfO6dTjEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikkmfwk0nV0p=omz2ddrw+ZqWF1Lx3EfO6dTjEQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 10, 2011 at 12:01:29PM -0800, Paul Menage wrote:
> On Wed, Mar 9, 2011 at 10:18 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> >> This BUG_ON() seems unnecessary, given the i++ directly above it.
> >
> > It's meant to communicate that the loop must go through at least once,
> > so that 'struct cgroup *oldcgrp' will be initialised within a loop later
> > (setting it to NULL in the beginning is just to shut up the compiler.)
> 
> Right, but it's a do {} while() loop with no break in it - it's
> impossible to not go through at least once...

OK; I guess it can go.

> > Although if the deal is that cancel_attach reverts
> > the things that can_attach does (and can_attach_task is separate) (is
> > this the case? it should probably go in the documentation), then passing
> > a can_attach and failing a can_attach_task should cause cancel_attach to
> > get called for that subsystem, which in this code it doesn't. Something
> > like:
> >
> > ? ?retval = ss->can_attach();
> > ? ?if (retval) {
> > ? ? ? ?failed_ss = ss;
> > ? ? ? ?goto out_cancel_attach;
> > ? ?}
> > ? ?retval = ss->can_attach_task();
> > ? ?if (retval) {
> > ? ? ? ?failed_ss = ss;
> > ? ? ? ?cancel_extra_ss = true;
> > ? ? ? ?goto out_cancel_attach;
> > ? ?}
> 
> Yes, but maybe call the flag cancel_failed_ss? Slightly more obvious,
> to me at least.

Sounds good.

> >> > + ? ? ? ? ? ? ? ? ? ? ? BUG_ON(!thread_group_leader(tsk));
> >>
> >> Can this race with an exiting/execing group leader?
> >
> > No, rcu_read_lock() is held.
> >
> 
> But rcu_read_lock() doesn't stop any actions - it just stops the data
> structures from going away. Can't leadership change during an
> execve()?

Hmm, you may be right; my understanding of RCU is not complete. But
actually I think the BUG_ON should just be removed, since we're about to
drop locks before handing off to cgroup_attach_proc anyway (so at no
important part is the assertion guaranteed), which will detect and
EAGAIN if such a race happened.

> > (However, I did try to test it, and it looks like if a leader calls
> > sys_exit() then the whole group goes away; is this actually guaranteed?)
> 
> I think so, but maybe not instantaneously.
> 
> Paul
> 

Hmm, well, should I make this assumption, then? The code would not be
more complicated either way, really. I kind of prefer it as it is...

-- Ben
