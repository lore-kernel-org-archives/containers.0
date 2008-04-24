From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 5/5] Add a Signal Control Group Subsystem
Date: Thu, 24 Apr 2008 00:00:27 -0700
Message-ID: <1209020428.20681.5.camel__14677.3864319131$1209020545$gmane$org@localhost.localdomain>
References: <20080423142517.062433911@us.ibm.com>
	<20080423142518.703428301@us.ibm.com> <480F5321.9030008@fr.ibm.com>
	<6599ad830804230837x48860632m7c41e425458ba6b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804230837x48860632m7c41e425458ba6b3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


On Wed, 2008-04-23 at 08:37 -0700, Paul Menage wrote:
> On Wed, Apr 23, 2008 at 8:17 AM, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
> > Hello Matt !
> >
> >  > Add a signal control group subsystem that allows us to send signals to all tasks
> >  > in the control group by writing the desired signal(7) number to the kill file.
> >  >
> >  > NOTE: We don't really need per-cgroup state, but control groups doesn't support
> >  > stateless subsystems yet.
> >  >
> >  > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >  > ---
> >  >  include/linux/cgroup_signal.h |   28 +++++++++
> >  >  include/linux/cgroup_subsys.h |    6 +
> >  >  init/Kconfig                  |    6 +
> >  >  kernel/Makefile               |    1
> >  >  kernel/cgroup_signal.c        |  129 ++++++++++++++++++++++++++++++++++++++++++
> >  >  5 files changed, 170 insertions(+)
> >
> >
> >  I think there is a small race with new tasks entering the cgroup
> >  while it's beeing killed, and a _fork ops would handle that. nop ?
> >
> 
> I never saw the actual patch (what lists did it go out to?) but I

Hi Paul,

	Sorry about this. MTA issues again :(. I think I've gotten them fixed
*this* time. I've resent them and you should have received your own copy
this time. Please let me know if you still aren't receiving them.

Cheers,
	-Matt
