From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Mon, 22 Aug 2011 19:39:49 +0200
Message-ID: <20110822173949.GA13242__18185.7439959005$1314035023$gmane$org@redhat.com>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>
	<20110815144744.GA9660@redhat.com> <4E4DA461.8030006@free.fr>
	<20110819152416.GA17034@redhat.com> <4E524B73.3050704@free.fr>
	<20110822154448.GA8527@redhat.com>
	<20110822183134.10390b46@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110822183134.10390b46-hY15tx4IgV39zxVx7UNMDg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/22, Bruno Pr=E9mont wrote:
>
> On Mon, 22 August 2011 Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On 08/22, Daniel Lezcano wrote:
> > >
> > > If we pass the reason to the exit_code of the init process, that will=
 be
> > > a bit weird as the process is signaled and did not exited  no ?
> >
> > Just in case, you shouldn't change ->exit_code blindly. We should only
> > change it if init was a) SIGKILL'ed and b) pid_ns->reboot_cmd is set.
> > In this case we can assume that it was killed by sys_reboot.
> >
> > Now. I didn't really mean exit_state should be equal to sys_reboot's
> > cmd arg. I thought about something like
> >
> > 	swicth (reboot_cmd) {
> > 	case LINUX_REBOOT_CMD_RESTART:
> > 		code =3D SIGHUP;
> > 		break;
> > 	case LINUX_REBOOT_CMD_HALT:
> > 		code =3D SIGINT;	// doesn't really matter what we report
> > 		...
> > 	}
>
> Isn't it possible to add the two cases to si_code possible values, e.g.
> CDL_RESTART, CDL_HALT (or CDL_SYS_RESTART, CDL_SYS_HALT

How? You should change do_wait() paths then. Even if we could, personally
I'd strongly object ;) Look, you have the very specific problem. The kernel
can't do everything to make everyone happy. There is tradeoff.

But if you really meant siginfo->si_code, I do not understand at all what
you actually mean. This info is not preserved when the task exits.

> to avoid possible
> confusion with CDL_STOPPED)?

How it is possible to confuse this with CDL_STOPPED?

> Then on sys_reboot() flag container init and kill it (this way sys_reboot=
()
> preserves its "will not return on success for restart/halt" scematic)?

This is what I suggested...

> Then container init would see CLD_KILLED replaced with matching reboot
> reason.

For what? its parent need this info, not container init. I guess I got
lost completely.

> Playing with the exit code is probably more problematic

OK, then please do something else. I do not pretend I really understand
what do you really need to solve your problem. But please do not forget
the kernel is already very complex and full of misc hacks ;)

> > And, iiuc, the point was to "fix" sys_reboot() so that we do not need
> > to mofify the distro/userspace?
>
> That's definitely the goal (not modify distro/userspace running inside
> container).

In this case I do not understand how prctl() can help.


But please do not try to convince me, this is simply unnecessary ;)

Oleg.
