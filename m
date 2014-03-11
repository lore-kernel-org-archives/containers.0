From: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [lxc-devel] [systemd-devel] Suspending access to opened/active
	/dev/nodes during application runtime
Date: Tue, 11 Mar 2014 12:02:46 -0400
Message-ID: <CAA4jN2Y0J3hWLM6mcAgFrtH-oYQFH57Hcrk7pz2KZdbBwO11SQ@mail.gmail.com>
References: <9D7BA6C9-9F1F-4D09-8F4F-E7DA4720FF97@gmail.com>
	<20140307192410.GA24453@tango.0pointer.de>
	<9E972401-6FA3-439B-9531-49D1FCC8D61D@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9E972401-6FA3-439B-9531-49D1FCC8D61D-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
Cc: systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Lennart Poettering <mzerqung-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 7, 2014 at 3:51 PM, Lukasz Pawelczyk <havner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

>
> On 7 Mar 2014, at 20:24, Lennart Poettering <mzerqung-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org> wrote:
>
> > On Fri, 07.03.14 19:45, Lukasz Pawelczyk (havner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> >
> >> Problem:
> >> Has anyone thought about a mechanism to limit/remove an access to a
> >> device during an application runtime? Meaning we have an application
> >> that has an open file descriptor to some /dev/node and depending on
> >> *something* it gains or looses the access to it gracefully (with or
> >> without a notification, but without any fatal consequences).
> >
> > logind can mute input devices as sessions are switched, to enable
> > unpriviliged X11 and wayland compositors.
>
> Would you please elaborate on this? Where is this mechanism? How does it
> work without kernel space support? Is there some kernel space support I'm
> not aware of?
>
> >> Example:
> >> LXC. Imagine we have 2 separate containers. Both running full operating
> >> systems. Specifically with 2 X servers. Both running concurrently of
> >
> > Well, devices are not namespaced on Linux (with the single exception of
> > network devices). An X server needs device access, hence this doesn't
> > fly at all.
> >
> > When you enumerate devices with libudev in a container they will never
> > be marked as "initialized" and you do not get any udev hotplug events in
> > containers, and you don#t have the host's udev db around, nor would it
> > make any sense to you if you had. X11 and friends rely on udev
> > however...
> >
> > Before you think about doing something like this, you need to fix the
> > kernel to provide namespaced devices (good luck!)
>
> Precisly! That's the generic idea. I'm not for implementing it though at
> this moment. I just wanted to know whether anybody actually though about it
> or maybe someone is interested in starting such a work, etc.
>

Yes, we have started such a thing. Here is the link to the wiki:
https://github.com/Cellrox/devns-patches/wiki

[...]

Oren.
