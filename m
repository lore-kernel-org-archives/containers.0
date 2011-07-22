From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/7] binfmt: Introduce the binfmt_img exec handler
Date: Fri, 22 Jul 2011 15:46:17 -0700
Message-ID: <20110722224617.GA16940@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com> <4E204519.3040804@parallels.com>
	<20110721065127.GS3455@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110721065127.GS3455-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 21, 2011 at 08:51:27AM +0200, Tejun Heo wrote:
> On Fri, Jul 15, 2011 at 05:48:09PM +0400, Pavel Emelyanov wrote:
> > When being execve-ed the handler reads registers, mappings and provided
> > memory pages from image and just assigns this state on current task. This
> > simple functionality can be used to restore a task, whose state whas read
> > from e.g. /proc/<pid>/dump file before.
> 
> Ummm... iff the process is single threaded. :(
> 
> Much more complex machinery is needed to restore full process anyway
> which would require some kernel facilities but definitely a lot more

Agreed,

> logic in userland.  I really can't see much point in having

I disagree (surprise! ;)).

> dumper/restorer in kernel.  The simplistic dumper/restorer proposed
> here isn't really useful - among other things, it's single threaded
> only and there's no mechanism to freeze the task being dumped.  It is

To be fair Pavel used signals to stop/resume the task. It's not
a good solution but it's a start (more below).

> almost trivially implementable from userland using existing
> facilities.  I wonder what the point is.

No, I think that ultimately an addition to the cgroup freezer will
be needed.

The problem is that another task (perhaps a shell or debugger)
could come in and wake up the tasks. In theory the same problem could
happen with the cgroup freezer -- only the fact that today code
is rarely written to deal with it allows it to be more reliable than
SIGSTOP and SIGCONT.

The task doing the checkpoint *at least* needs to know if the frozen
tasks have been thawed ("notification"). That allows it to report
a warning or an error to the effect that the checkpoint may be
unreliable. Notification alone produces the possibility of indefinite
postponement however.

So it needs some assurance that frozen tasks will not be thawed until
checkpoint is complete. Oren's patches used a new freezer state
for this purpose. That's an in-kernel solution -- we need something
somewhat more elaborate for userspace because we then have to worry
about abuse of a new freezer interface.

We could add the ability to "lock" the freezer in its current state
to userspace. Only the task that set the lock can release it. Of
course if the task died then the lock would need to be released. It
might also be wise to add a timeout...

So we almost want to be able to use a mandatory file lock on the
freezer.state. Or perhaps we can add a freezer.lock file to the
cgroup freezer.

But for now, using the cgroup freezer would be an improvement
over SIGSTOP/SIGCONT.

Cheers,
	-Matt Helsley
