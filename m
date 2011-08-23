From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Tue, 23 Aug 2011 15:33:02 +0200
Message-ID: <20110823133302.GA19582__26495.2175006785$1314106639$gmane$org@redhat.com>
References: <20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>
	<20110815144744.GA9660@redhat.com> <4E4DA461.8030006@free.fr>
	<20110819152416.GA17034@redhat.com> <4E524B73.3050704@free.fr>
	<20110822154448.GA8527@redhat.com>
	<20110822183134.10390b46@neptune.home>
	<20110822173949.GA13242@redhat.com>
	<20110822211716.7c141d5c@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110822211716.7c141d5c-hY15tx4IgV39zxVx7UNMDg@public.gmane.org>
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
> On Mon, 22 August 2011 Oleg Nesterov wrote:
> > On 08/22, Bruno Pr=E9mont wrote:
> > >
> > > Isn't it possible to add the two cases to si_code possible values, e.=
g.
> > > CDL_RESTART, CDL_HALT (or CDL_SYS_RESTART, CDL_SYS_HALT
> >
> > How? You should change do_wait() paths then. Even if we could, personal=
ly
> > I'd strongly object ;) Look, you have the very specific problem. The ke=
rnel
> > can't do everything to make everyone happy. There is tradeoff.
> >
> > But if you really meant siginfo->si_code, I do not understand at all wh=
at
> > you actually mean. This info is not preserved when the task exits.
>
> I've been reading do_wait() code a bit, it decides between CLD_KILLED and
> CLD_DUMPED based on a bit of (struct task_struct).exit_code.

Yes. But we were talking about the CLD_EXITED/CLD_KILLED difference.
And in fact this CLD_ doesn't matter at all. sys_waitid(info) can see
it, but you can simply look at "status". There is no additional info.

> So struct_task IS still available

Sure. But I do not understand why do you mention this... And, I think,
in this discussion we can pretend that only task->exit_code is still
available.

> (how about it's namespace references? If
> the namespaces are not the reboot reason would need to be stored somewhere
> inside of struct task which might be some overhead too much)
>
> So as long as container init's task_struct exists the reboot reason could
> be preserved and used to replace CLD_DUMPED/CLD_KILLED siginfo->si_code.

At least now I understand why did you mention si_code/CLD before. You
meant waitid(). I thought you were talking about the death-notifications
which can't report CLD_ you need.

I strongly object. We shouldn't uglify wait_task_zombie() to solve the
very specific problem.

And once again. sub_init->parent does wiat(&status) and sees
WIFSIGNALED() && WTERMSIG(status) =3D=3D SIGHUP. This can only mean that
sys_reboot(LINUX_REBOOT_CMD_RESTART) was called. It _can not_ be really
killed by SIGHUP, it must be CMD_RESTART.

Why this can't work? Why do you want the additional complications?

> > > > And, iiuc, the point was to "fix" sys_reboot() so that we do not ne=
ed
> > > > to mofify the distro/userspace?
> > >
> > > That's definitely the goal (not modify distro/userspace running inside
> > > container).
> >
> > In this case I do not understand how prctl() can help.
>
> I'm not talking about prctl() - as I understand Daniel the prctl() part is
> for the process outside of the container, not the one inside.
> So for container hypervisor to say if it wants to get informed or not.

OK, I certainly misunderstood him. And still can't understand what
exactly was suggested ;)

> > But please do not try to convince me, this is simply unnecessary ;)
>
> No, trying to know what's reasonably possible

Can't resist... IMHO, imho, imho, but in this case I believe
"reasonably possible" =3D=3D "simplest" ;)

Oleg.
