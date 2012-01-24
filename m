From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [RFC] fix devpts mount behavior
Date: Tue, 24 Jan 2012 17:16:01 -0600
Message-ID: <20120124231601.GA4470@sergelap>
References: <20120124000517.GA28878@sergelap>
	<CA+55aFz9ofF+Ey8VCDS8UEf2XSw36kj2RhkHfFScuzLXMeNrkA@mail.gmail.com>
	<20120124002555.GA29534@sergelap>
	<CA+55aFzwOU137V6wtyBjessx05NJo2G4KV0rvTKWvC79A+o9iQ@mail.gmail.com>
	<20120124010758.GJ23916@ZenIV.linux.org.uk>
	<m1k44gj1cu.fsf@fess.ebiederm.org>
	<20120124220247.GA26353@hallyn.com>
	<CAPXgP13_gczQmG_USAp0p2AuTfxkzAvzHvjbZY_rbbLH-4rDyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAPXgP13_gczQmG_USAp0p2AuTfxkzAvzHvjbZY_rbbLH-4rDyg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Kay Sievers (kay.sievers-tD+1rO4QERM@public.gmane.org):
> On Tue, Jan 24, 2012 at 23:02, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> =

> >> It looks like relatively recent udev still creates /dev/ptmx and does
> >
> > Boy, it does, and it's stubborn about it. =A0Removing the /lib/udev/rul=
es.d
> > entry doesn't stop it. =A0(this is after I've had an init job replace t=
he
> > devtmpfs-created ptmx entry with a symlink)
> =

> Udev has nothing to do with that. The kernel creates that device node.
> Udev does not carry any rules you could remove, to name device nodes,
> it only set permissions and creates symlinks to device nodes.

That's odd, because I was sure I deleted the node after the kernel created
it.

But it sounds like I must have done it wrong.

> It will never replace a kernel-created device node with a symlink,
> there is no way to express that. If you don't want a device node
> there, you need to change the kernel, to not export
> /sys/class/tty/ptmx/ the way it is today.
> =

> > So current distros (well, Ubuntu and Fedora at least) would need to at =
least
> > (a) fix udev,
> =

> To do what?

Nothing, as I'm sure you're right above  :)

> > (b) change the default devpts mount (done from initramfs) to
> > add ptmxmode=3D666,
> =

> > (c) (if not done in udev) create the /dev/ptmx symlink.
> =

> Udev can only create symlinks to devices the driver-core creates, not
> to devices inside a custom filesystem.

I see.

> > For safety I'd recommend creating /dev/pts/ptmx with
> > DEVPTS_MULTIPLE_INSTANCES=3Dn (or dropping that support), and by default
> > setting ptmxmode to 666 as that's what udev does.
> =

> The mode for ptmx is set by the kernel itself, and does not even need
> udev to do that:
>   $ cat /sys/class/tty/ptmx/uevent
>   MAJOR=3D5
>   MINOR=3D2
>   DEVNAME=3Dptmx
>   DEVMODE=3D0666

That has nothing to do with /dev/pts/ptmx, whose perms are set based on
the '-o ptmxmode=3D" argument, and default to 000 if not specified.  If
/dev/ptmx is going to be a symlink to /dev/pts/ptmx, then we have to set
the /dev/pts/ptmx perms to not be 000, or users won't be able to create
ptys.

-serge
