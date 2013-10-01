From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: Device Namespaces
Date: Tue, 1 Oct 2013 13:57:18 -0700
Message-ID: <20131001205718.GA17036@kroah.com>
References: <CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com> <20130926053320.GB3725@kroah.com>
	<CAE=NcrYV2RiMV7PcwEjFGFRBrz9XdZGs86Wau2a+6xpYN2aEHA@mail.gmail.com>
	<CALCETrWWoHzuJcnfEUY+cFpOgT5gnG8U1cVbCW0_8V7Z_v6DJw@mail.gmail.com>
	<20131001175345.GA4145@mail.hallyn.com>
	<87had0wz07.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87had0wz07.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, devel <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 01, 2013 at 12:51:36PM -0700, Eric W. Biederman wrote:
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
> >> On Tue, Oct 1, 2013 at 7:19 AM, Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> > On Thu, Sep 26, 2013 at 8:33 AM, Greg Kroah-Hartman
> >> > <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:
> >> >
> >> >>> - We can relay a call of /sbin/hotplug from outside of a container
> >> >>>   to inside of a container based on policy.
> >> >>>   (But no one uses /sbin/hotplug anymore).
> >> >>
> >> >> That's right, they should be listening to libudev events, so why can't
> >> >> your daemon shuffle them off to the proper container, all in userspace?
> >> >
> >> > Which reminds me, one potential reason being..
> >> > http://lists.linuxfoundation.org/pipermail/containers/2013-May/032591.html
> >> >
> >> 
> >> Can't the daemon live outside the container and shuffle stuff in?
> >
> > That's exactly what Michael Warfield is suggesting, fwiw.
> 
> Michael Warfields example of dynamically assigning serial ports to
> containers is a pretty good test case.  Serial ports are extremely well
> known kernel objects who evolution effectively stopped long ago.  When
> we need it we have ptys to virtual serial ports when we need it, but in
> general unprivileged users are safe to directly use a serial port
> device.
> 
> Glossing over the details.  The general problem is some policy exists
> outside of the container that deciedes if an when a container gets a
> serial port and stuffs it in.
> 
> The expectation is that system containers will then run the udev
> rules and send the libuevent event.  
> 
> To make that all work without kernel modifications requires placing
> a faux-udev in the container, that listens for a device assignment from
> outside the container and then does exactly what udev would have done.
> 
> The problems with this that I see are:
> 
> - udev is a moving target making it hard to build a faux-udev that will
>   work everywhere.

How is udev a moving target?  Use libudev and all should be fine, that's
an ABI you can rely on, right?

Or, if you don't like/want udev, use mdev in your container.  Or
something else, what does this have to do with the kernel?

> - On distro's running systemd and udev integration is sufficiently tight
>   that I am not certain a faux-udev is possible or will continue to be
>   possible.

That's not a kernel issue, that's a "ouch, this is hard, let's give up"
issue.

Or perhaps it is a "maybe I shouldn't even be trying to do this" type
issue... :)

> - There are two other widely deployed solutions for managing hotplug
>   devices besides udev.

I know of mdev, what's the other one?  The hacked-up shell script that
Android uses?  Or something else?

> So given these difficulties I do not believe that the evolution of linux
> device management is done, and that patches to udev, the kernel or both
> will be needed.  While it would be good for testing and understanding
> the problem I don't think a faux-udev will be a long term maintainable
> solution.

You are saying that for some reason you feel helpless with the way
userspace is going, so we have to change the kernel.  That's horrible,
and is not going to be a reason I accept to change the kernel, sorry.

> I also understand the point that we aren't talking patches yet and just
> discussing ideas.  Right now it is my hope that if we talk this out we
> can figure out a general direction that has a hope of working.
> 
> From where I am standing faking uevents instead of replacing
> udev/mdev/whatever looks simpler and more maintainable.

Have you really looked into this?  Numerous people, who understand this
code path and userspace issues, have said it is not a good idea at all.

But hey, what do I know...

I still have yet to see a reason why you can't use libudev today for
something like this.

Anyway, I'm done discussing this as it's pointless this early, I'm going
to refrain for any more pithy comments until someone posts some code, as
this is just wasting people's time at the moment.

greg k-h
