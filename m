From: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: RFC: Device Namespaces
Date: Mon, 26 Aug 2013 06:11:52 -0400
Message-ID: <CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
References: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
	<20130822182118.GA28331@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130822182118.GA28331@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Serge,


On Thu, Aug 22, 2013 at 2:21 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>wrot=
e:

> Quoting Oren Laadan (orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org):
> > Hi everyone!
> >
> > We [1] have been working on bringing lightweight virtualization to
> > Linux-based mobile devices like Android (or other Linux-based devices
> with
> > diverse I/O) and want to share our solution: device namespaces.
> >
> > Imagine you could run several instances of your favorite mobile OS or
> other
> > distributions in isolated containers, each under the impression of havi=
ng
> > exclusive access to device drivers; Interact and switch between them
> within
> > a blink, no flashing, no reboot.
> >
> > Device namespaces are an extension to existing Linux kernel namespaces
> that
> > brings lightweight virtualization to Linux-based end-user devices,
> > primarily mobile devices.
> > Device namespaces introduce a private and virtual namespace for device
> > drivers to create the illusion for a process group that it interacts
> > exclusively with a set of drivers. Device namespaces also introduce the
> > concepts of an =93active=94 namespace with which a user interacts, vs
> > =93non-active=94 namespaces that run in the background, and the ability=
 to
> > switch between them.[2]
>
> Note that unless I'm misunderstanding what you're saying here, this is
> also what net_ns does.  A netns can exist with no processes so long as
> you've bound its /proc/$$/ns/net somewhere.  You can then re-enter that
> ns using ns_attach.  I haven't looked closely enough yet to see whether
> you should be (or are) using the same interface.
>
>
To illustrate the need for device namespaces, consider the use case of
running two containers of your favorite OS (say, Android), on a single
physical phone. As a user, you either work in one container, or in the
other, and you will want to be able to switch between them (just like with
apps on mobile devices: you interact with one application at a time, and
switch between them).

See here for a demo of how it works:  http://vimeo.com/60113683

To accomplish this, device namespaces solve two shortcomings of existing
namespaces:

1. A namespace for device drivers:  each (Android) container needs a
private view of all devices. This includes logical drivers, like binder (in
Android) but also loop device; and physical devices, like the framebuffer
and the touch-screen.

In other words, device namespaces virtualize the _major/minor_ and the
_state_ of device drivers. With the exception of VFS, network, and PTY
(note: all three offer/are virtual devices), device drivers are otherwise
not isolated between containers.

2. A namespace for interactive scenarios:  a namespace can be "active" - it
has access to the hardware, e.g. display and touch-screen. This will be the
container with which the user is interacting right now. Otherwise a
namespace is "non-active" - it still runs in the background, but can
neither alter the display nor receive input from the touch-screen.
Switching to another container means a context switch in the relevant
drivers, so that they restore the state and now "obey" the other namespace.

You can also think about the "active" namespace as foreground, and the
"non-active" as background, akin to foreground/background processes in a
terminal with job-control. Similar to how a terminal delivers input to the
foreground task only but not to the background tasks - this is enforced by
the new device namespace.

More details on this use-case are in the wiki:
https://github.com/Cellrox/devns-patches/wiki/Thinvisor).


> We are planning to prepare individual patches to be submitted to the
>
> Looking forward to it, and seeing you at the containers track  :)
>

Same here!


>
> > 2: https://github.com/Cellrox/devns-patches/wiki/DeviceNamespace
> > 3: https://github.com/Cellrox/devns-patches
> > 4: https://github.com/Cellrox/devns-demo
>
> (Have looked over the wiki, will look over the patches as well)
>
> -serge
>


Thanks,

Oren.

-- =

 Oren Laadan
 Cellrox Ltd.
