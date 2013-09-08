From: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: RFC: Device Namespaces
Date: Sun, 8 Sep 2013 14:28:55 +0200
Message-ID: <CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
References: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
	<20130822182118.GA28331@sergelap>
	<CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
	<8761udlu0d.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8761udlu0d.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 6, 2013 at 7:50 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>wr=
ote:

> Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org> writes:
>
> > Hi Serge,
> >
> >
> > On Thu, Aug 22, 2013 at 2:21 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
> >wrote:
> >
> >> Quoting Oren Laadan (orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org):
> >> > Hi everyone!
> >> >
> >> > We [1] have been working on bringing lightweight virtualization to
> >> > Linux-based mobile devices like Android (or other Linux-based devices
> >> with
> >> > diverse I/O) and want to share our solution: device namespaces.
> >> >
> >> > Imagine you could run several instances of your favorite mobile OS or
> >> other
> >> > distributions in isolated containers, each under the impression of
> having
> >> > exclusive access to device drivers; Interact and switch between them
> >> within
> >> > a blink, no flashing, no reboot.
> >> >
> >> > Device namespaces are an extension to existing Linux kernel namespac=
es
> >> that
> >> > brings lightweight virtualization to Linux-based end-user devices,
> >> > primarily mobile devices.
> >> > Device namespaces introduce a private and virtual namespace for devi=
ce
> >> > drivers to create the illusion for a process group that it interacts
> >> > exclusively with a set of drivers. Device namespaces also introduce
> the
> >> > concepts of an =93active=94 namespace with which a user interacts, vs
> >> > =93non-active=94 namespaces that run in the background, and the abil=
ity to
> >> > switch between them.[2]
> >>
> >> Note that unless I'm misunderstanding what you're saying here, this is
> >> also what net_ns does.  A netns can exist with no processes so long as
> >> you've bound its /proc/$$/ns/net somewhere.  You can then re-enter that
> >> ns using ns_attach.  I haven't looked closely enough yet to see whether
> >> you should be (or are) using the same interface.
> >>
> >>
> > To illustrate the need for device namespaces, consider the use case of
> > running two containers of your favorite OS (say, Android), on a single
> > physical phone. As a user, you either work in one container, or in the
> > other, and you will want to be able to switch between them (just like
> with
> > apps on mobile devices: you interact with one application at a time, and
> > switch between them).
> >
> > See here for a demo of how it works:  http://vimeo.com/60113683
> >
> > To accomplish this, device namespaces solve two shortcomings of existing
> > namespaces:
> >
> > 1. A namespace for device drivers:  each (Android) container needs a
> > private view of all devices. This includes logical drivers, like binder
> (in
> > Android) but also loop device; and physical devices, like the framebuff=
er
> > and the touch-screen.
> >
> > In other words, device namespaces virtualize the _major/minor_ and the
> > _state_ of device drivers. With the exception of VFS, network, and PTY
> > (note: all three offer/are virtual devices), device drivers are otherwi=
se
> > not isolated between containers.
> >
> > 2. A namespace for interactive scenarios:  a namespace can be "active" -
> it
> > has access to the hardware, e.g. display and touch-screen. This will be
> the
> > container with which the user is interacting right now. Otherwise a
> > namespace is "non-active" - it still runs in the background, but can
> > neither alter the display nor receive input from the touch-screen.
> > Switching to another container means a context switch in the relevant
> > drivers, so that they restore the state and now "obey" the other
> namespace.
> >
> > You can also think about the "active" namespace as foreground, and the
> > "non-active" as background, akin to foreground/background processes in a
> > terminal with job-control. Similar to how a terminal delivers input to
> the
> > foreground task only but not to the background tasks - this is enforced
> by
> > the new device namespace.
> >
> > More details on this use-case are in the wiki:
> > https://github.com/Cellrox/devns-patches/wiki/Thinvisor).
>
> I think this is going to take some talking, and looking at code.
>
>
Hi Eric,

If we can get people to take a quick look at the code before LPC
that could make the LPC discussions more effective.
Even looking at one of the subsystem patches can give a basic
idea of the work we have done:
https://github.com/Cellrox/linux/commits/devns-goldfish-3.4

I think you are talking about having wrappers around your devices so you
> can share.  Which is not the quite same problem the rest of us have been
> thinking of when talking about a device namespace.
>

We are interested in all problems related to virtualizated view of devices
inside a container, so let our work so far be a starting point to discuss
all of them.


>
> My first impression is that this is better solved with more appropriate
> abstractions in userspace or in the kernel.
>
> But we can talk at LPC and see what we can hash out.
>

Looking forward to that :-)

Amir.


>
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>
