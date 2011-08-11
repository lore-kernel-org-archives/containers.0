From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC] catching sys_reboot syscall
Date: Thu, 11 Aug 2011 13:10:23 -0500
Message-ID: <20110811181022.GA12307__35161.7513843395$1313086288$gmane$org@peqn>
References: <4E4051A0.8030009@free.fr> <20110810221028.2e0c8590@neptune.home>
	<4E42EEE3.9050608@free.fr> <20110811183027.49275b2d@neptune.home>
	<4E44082F.6040606@free.fr> <20110811190456.77ff9280@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110811190456.77ff9280-hY15tx4IgV39zxVx7UNMDg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LXC Development <Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Bruno Pr=E9mont (bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org):
> On Thu, 11 August 2011 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
> > On 08/11/2011 06:30 PM, Bruno Pr=E9mont wrote:
> > > On Wed, 10 August 2011 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
> > >> On 08/10/2011 10:10 PM, Bruno Pr=E9mont wrote:
> > >>> Hi Daniel,
> > >>>
> > >>> [I'm adding containers ml as we had a discussion there some time ago
> > >>>  for this feature]
> > >> [ ... ]
> > >>
> > >>>> +    if (cmd =3D=3D LINUX_REBOOT_CMD_RESTART2)
> > >>>> +        if (strncpy_from_user(&buffer[0], arg, sizeof(buffer) - 1=
) < 0)
> > >>>> +            return -EFAULT;
> > >>>> +
> > >>>> +    /* If we are not in the initial pid namespace, we send a sign=
al
> > >>>> +     * to the parent of this init pid namespace, notifying a shut=
down
> > >>>> +     * occured */
> > >>>> +    if (pid_ns !=3D &init_pid_ns)
> > >>>> +        pid_namespace_reboot(pid_ns, cmd, buffer);
> > >>> Should there be a return here?
> > >>> Or does pid_namespace_reboot() never return by submitting signal to
> > >>> parent?
> > >> Yes, it does not return a value, like 'do_notify_parent_cldstop'
> > > So execution flow continues reaching the whole "host reboot code"?
> > >
> > > That's not so good as it then prevents using CAP_SYS_BOOT inside PID =
namespace
> > > to limit access to rebooting the container from inside as giving a pr=
ocess
> > > inside container CAP_SYS_BOOT would cause host to reboot (and when no=
t given
> > > process inside container would get -EPERM in all cases).
> > >
> > > Wouldn't the following be better?:
> > > ...
> > > +
> > > +    /* We only trust the superuser with rebooting the system. */
> > > +    if (!capable(CAP_SYS_BOOT))
> > > +        return -EPERM;
> > > +
> > > +    /* If we are not in the initial pid namespace, we send a signal
> > > +     * to the parent of this init pid namespace, notifying a shutdown
> > > +     * occured */
> > > +    if (pid_ns !=3D &init_pid_ns) {
> > > +        pid_namespace_reboot(pid_ns, cmd, buffer);
> > > +        return 0;
> > > +    }
> > > +
> > >      mutex_lock(&reboot_mutex);
> > >      switch (cmd) {
> > > ...
> > >
> > >
> > > If I misunderstood, please correct me.
> > =

> > Yep, this is what I did at the beginning but I realized I was closing
> > the door for future applications using the pid namespaces. The pid
> > namespace could be used by another kind of application, not a container,
> > running some administrative tasks so they may want to shutdown the host
> > from a different pid namespace.
> > =

> > For this reason, to prevent this execution flow, the container has to
> > drop the CAP_SYS_BOOT in addition of taking care of the SIGCHLD signal
> > with CLDREBOOT.
> =

> Ok, though for later source code readers to know adding/extending comment
> would be nice.
> Maybe something like
> =

> +    /* If we are not in the initial pid namespace, we send a signal
> +     * to the parent of this init pid namespace, notifying a shutdown
> +     * occured
> +     * NOTE: if process has CAP_SYS_BOOT it will additionally have the
> +     * same effect as if it was not namespaced */
> =

> =

> How would all of this integrate with the ongoing work on user namespaces?
> Maybe that one should later be the differentiator for who may or may not
> trigger the host reboot.

Right, then you'll be able to do:

	if (ns_capable(current_pid_ns()->user_ns, CAP_SYS_BOOT)) {
		// do container reboot stuff
	}

	if (!capable(CAP_SYS_BOOT)
		return;

	// do host reboot stuff

The first checks whether the task has privilege against the user ns
which owns his pid_ns.

The second one is a synonym for

	if (!ns_capable(&init_user_ns, CAP_SYS_BOOT))

where init_user_ns is the owner of all physical resources.

Right now pid_ns doesn't yet have a user_ns owner (except in my patch over
here: http://kernel.ubuntu.com/git?p=3Dserge/linux-syslogns.git;a=3Dcommit;=
h=3D63556e9a39bcd75ec4a88333425800905013c73e )
and, if it did, well you can't yet do enough in a user namespace to run
a container.  But that'll be the ideal.  Hopefully soon...

-serge
