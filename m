From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/4] Container Freezer: Reuse Suspend Freezer
Date: Tue, 08 Jul 2008 12:39:14 -0700
Message-ID: <1215545954.9023.120.camel__7671.5778363452$1215547189$gmane$org@localhost.localdomain>
References: <20080707225823.502032693@us.ibm.com>
	<20080708123150.3034d83f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080708123150.3034d83f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Cedric was accidentally not Cc'd on the introduction (PATCH 0). Adding
him.

On Tue, 2008-07-08 at 12:31 +0900, KAMEZAWA Hiroyuki wrote:
> Hi, could I make brief questions ?
> 
> On Mon, 07 Jul 2008 15:58:23 -0700
> Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > to get status of the freezer subsystem :
> > 
> >    # cat /containers/0/freezer.state
> >    RUNNING
> > 
> > to freeze all tasks in the container :
> > 
> >    # echo FROZEN > /containers/0/freezer.state
> >    # cat /containers/0/freezer.state
> >    FREEZING
> >    # cat /containers/0/freezer.state
> >    FROZEN
> > 
> I'm just curious.
> 
> 1. When we see FREEZING and have to retry ?

One example is when some processes are in the a specific portion of
vfork() you might see FREEZING and have to retry.

>    While there are some threads which wait for some event ?

Depending on which kind of "wait" they are performing, yes. If it's
uninterruptible sleep and the PF_FROZEN flag is not set then you might
see FREEZING.

> 2. What happens when FROZEN threads are moved to other group ?
>    Can we move them ?

If the destination cgroup is not FROZEN, yes.

If the destination cgroup is FREEZING this works as expected.

If the destination cgroup is RUNNING you'd have a problem unfreezing the
task. This happends because the cgroup has a state inconsistent with the
task's state. To unfreeze the task you'd have to try to freeze and then
unfreeze the destination cgroup. 

There are several ways I could change this.

One is to try and disallow users from moving frozen tasks. That doesn't
seem like a good approach since it would require a new cgroups interface
"can_detach()". 

However we can prevent attach so I could add checks that look at the
attaching tasks's state and refuse the attach when the task's state
(unfrozen, frozen) is inconsistent with the cgroup state (RUNNING,
FREEZING, FROZEN). I'll send a fifth patch on top of this series showing
this idea.

Rather than refuse to allow attach we could change the destination
cgroup's state during attach so that the two states are consistent.
However, this introduces more ugly cases for userspace to be aware of.

>    Can we wake them up (if it can be moved) ?

You can't wake them until you've unfrozen them.

>    What operations are allowed to frozen threads ?

Any operation that doesn't require the threads to run.

Cheers,
	-Matt Helsley
