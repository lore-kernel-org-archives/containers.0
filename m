From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC PIDs, UIDs, and halt
Date: Wed, 14 Oct 2009 19:42:13 -0500
Message-ID: <68e6eac60910141742h557f558cke749cd76d5706f83@mail.gmail.com>
References: <68e6eac60910110930q74358967o19e3d0e88e111bd5@mail.gmail.com>
	<20091012150355.GA5783@us.ibm.com>
	<68e6eac60910122206i7c39fca0u52ab037748217336@mail.gmail.com>
	<20091013195921.GA20345@us.ibm.com>
	<68e6eac60910131318w56d9394bs9191f989b16e34f3@mail.gmail.com>
	<20091014040222.GA4710@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091014040222.GA4710-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 13, 2009 at 11:02 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > On Tue, Oct 13, 2009 at 2:59 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> wrote:
> >
> > > Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > > > On Mon, Oct 12, 2009 at 10:03 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > wrote:
> > > >
> > > > > Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > > > > > 4) In a opensuse container when I execute "halt" it is not just
> the
> > > > > > container that halts, but the controlling host as well that shuts
> > > down.
> > > > >
> > > > > Make sure that the container is launched with CAP_SYS_BOOT removed
> from
> > > > > the capability bounding set.
> > > > >
> > > >
> > > > Ok, well it turns out any container can halt the whole system.
> > > >
> > > > If I do:
> > > >   capsh --drop="cap_sys_boot" -- -c "lxc-start -n arch-test0"
> > > > Then do a halt within the container, the halt still works.
> > > > A "reboot" within a container does not reboot the controlling host,
> the
> > > > container runs the shutdown scripts and then idles.
> > > >
> > > > However, if on the controlling host I do:
> > > >   capsh --drop="cap_kill" -c "bash --login -i"
> > > > Then the subsequent shell can't use kill which I have verified.
> > > >
> > > > Well, these performed on the controlling host:
> > > >   capsh --drop="cap_sys_boot" -- -c "halt"
> > > >   capsh --drop="cap_sys_boot" -- -c "reboot"
> > > >
> > > > Still halt and reboot my system.
> > > >
> > > > So I know that capabilities are working, I just have not figured out
> yet
> > > how
> > > > to prevent containers from being able to halt the controlling host
> (short
> > > of
> > > > simply not executing "halt" within a container or renaming/removing
> > > "halt"
> > > > and "shutdown" but then "init 0" would still work).
> > > >
> > > > CAP_SYS_BOOT seems to control reboot, which has not been an issue,
> I've
> > > not
> > > > gotten a container to reboot the controlling host.
> > >
> > > HAH!  It's upstart, the latest incarnation of init (at least on
> Fedora).
> > >  It
> > > takes commands over an abstract unix domain socket, "
> > > /com/ubuntu/upstart/<pid>".  If you start your container in a new
> network
> > > namespace, then halt fails.
> > >
> > > I haven't gone through the code enough to see exactly how, then,
> > > upstart (in userspace) authorizes the halt request.  Since 'pid'
> > > is encoded in the socket name, i assume it looks at /proc/pid/status.
> > > So it easily could check for CAP_SYS_BOOT \notin pE, or even
> > > check whether it's supposed to be in a container (using some config
> > > files in userspace if somesuch could be agreed upon by everyone, not
> > > really likely).
> > >
> > > Oh, yeah, upstart-0.3.11/init/main.c checks whether geteuid()==0.
> > > Wonderful.
> > >
> > > -serge
> > >
> >
> > I'm on archlinux. I don't beleive it is upstart: /sbin/init is owned by
> > sysvinit 2.86-5
> >
> > The following looks like the likely suspect:
> > init         1    root   10u     FIFO               0,14         0t0
> > 1723 /dev/initctl
> >
> > I might be able to fix that with SMACK? I'll look into that tonight.
>
> Ah, you don't have to do that - initctl is a fifo, so as long as you
> make sure not to bind-mount it from the host container it should be
> fine.  If the guest creates it's own, it'll be a different fifo and
> not talk to init.
>
> -serge
>

Yeah, I had been bind mounting all of /dev..... I'm now just mounting the
following:

none   CN_ROOT/dev/pts    devpts    defaults 0 0
none   CN_ROOT/proc    proc    defaults 0 0
none   CN_ROOT/sys    sysfs    defaults 0 0
none   CN_ROOT/dev/shm    tmpfs    defaults 0 0

And I made a minimal CN_ROOT/dev:
crw------- 1 root root 5, 1 2009-10-14 18:36 console
crw-rw-rw- 1 root root 1, 7 2009-10-14 18:35 full
prw------- 1 root root    0 2009-10-14 18:56 initctl
srw-rw-rw- 1 root root    0 2009-10-14 19:09 log
crw-rw-rw- 1 root root 1, 3 2009-10-14 18:35 null
crw-rw-rw- 1 root root 5, 2 2009-10-14 19:11 ptmx
drwxr-xr-x 2 root root    1 2009-10-14 18:35 pts
crw-rw-rw- 1 root root 1, 8 2009-10-14 18:35 random
drwxrwxrwt 2 root root    1 2009-10-14 18:35 shm
crw-rw-rw- 1 root root 5, 0 2009-10-14 18:37 tty
crw-rw-rw- 1 root root 4, 0 2009-10-14 18:35 tty0
crw-rw-rw- 1 root root 1, 9 2009-10-14 18:35 urandom
prw-r----- 1 root adm     0 2009-10-14 19:17 xconsole
crw-rw-rw- 1 root root 1, 5 2009-10-14 18:35 zero

Thanks for the help Serge!

-- Dwight
