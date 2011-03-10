From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8 3/3] cgroups: make procs file writable
Date: Thu, 10 Mar 2011 12:01:29 -0800
Message-ID: <AANLkTikkmfwk0nV0p=omz2ddrw+ZqWF1Lx3EfO6dTjEQ__1106.83339084989$1299787835$gmane$org@mail.gmail.com>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013950.GF31569@ghc17.ghc.andrew.cmu.edu>
	<AANLkTinEnNsu8=PEktXL_EECzGYqsgdf+uogGxe7k4W+@mail.gmail.com>
	<20110310061831.GA23736@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110310061831.GA23736-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Mar 9, 2011 at 10:18 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>> This BUG_ON() seems unnecessary, given the i++ directly above it.
>
> It's meant to communicate that the loop must go through at least once,
> so that 'struct cgroup *oldcgrp' will be initialised within a loop later
> (setting it to NULL in the beginning is just to shut up the compiler.)

Right, but it's a do {} while() loop with no break in it - it's
impossible to not go through at least once...

>> Should we be setting failed_ss here? Doesn't that mean that if all
>> subsystems pass the can_attach() check but the first one fails a
>> can_attach_task() check, we don't call any cancel_attach() methods?
>>
>> What are the rollback semantics for failing a can_attach_task() check?
>
> They are not called in that order - it's for_each_subsys { can_attach();
> can_attach_task(); }.

Oh, fair point - I misread that.

> Although if the deal is that cancel_attach reverts
> the things that can_attach does (and can_attach_task is separate) (is
> this the case? it should probably go in the documentation), then passing
> a can_attach and failing a can_attach_task should cause cancel_attach to
> get called for that subsystem, which in this code it doesn't. Something
> like:
>
> =A0 =A0retval =3D ss->can_attach();
> =A0 =A0if (retval) {
> =A0 =A0 =A0 =A0failed_ss =3D ss;
> =A0 =A0 =A0 =A0goto out_cancel_attach;
> =A0 =A0}
> =A0 =A0retval =3D ss->can_attach_task();
> =A0 =A0if (retval) {
> =A0 =A0 =A0 =A0failed_ss =3D ss;
> =A0 =A0 =A0 =A0cancel_extra_ss =3D true;
> =A0 =A0 =A0 =A0goto out_cancel_attach;
> =A0 =A0}

Yes, but maybe call the flag cancel_failed_ss? Slightly more obvious,
to me at least.

>> > + ? ? ? ? ? ? ? ? ? ? ? BUG_ON(!thread_group_leader(tsk));
>>
>> Can this race with an exiting/execing group leader?
>
> No, rcu_read_lock() is held.
>

But rcu_read_lock() doesn't stop any actions - it just stops the data
structures from going away. Can't leadership change during an
execve()?

> (However, I did try to test it, and it looks like if a leader calls
> sys_exit() then the whole group goes away; is this actually guaranteed?)

I think so, but maybe not instantaneously.

Paul
