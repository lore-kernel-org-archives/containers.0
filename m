From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 2/3] lib/kobject_uevent.c: add uevent forwarding function
Date: Wed, 9 Sep 2015 22:58:34 -0700
Message-ID: <20150910055834.GB31213@kroah.com>
References: <cover.1441762578.git.michael.coss@alcatel-lucent.com>
	<3456750fe7a5a5eb709e315618facf5704cc1885.1441762578.git.michael.coss@alcatel-lucent.com>
	<20150909035527.GB5153@kroah.com>
	<55F0875C.6060108@alcatel-lucent.com>
	<20150909201123.GC9328@kroah.com>
	<CAA2m6vcnUz4EeS-FH2P=GjKSquXit=j1NE5Yut8_baLA+TvjJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAA2m6vcnUz4EeS-FH2P=GjKSquXit=j1NE5Yut8_baLA+TvjJA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Cc: Michael J Coss <michael.coss-cfy2TCaE7SFv+uJa97DSA9BPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Sep 10, 2015 at 08:43:28AM +0300, Amir Goldstein wrote:
> I fully agree with you that running unmodified distro inside a
> container is not a justified
> cause for kernel changes.

Great, end of discussion :)

> However, I would like to highlight the point that udev is not the only
> consumer of uevents, so changing userspace, as you rightfully
> suggested, may not be as simple as you imagine.

But you have control over who consumes uevents, so if you really want to
create such a "only send some uevents to some containers" you can do so
from the "host" container today.  Exactly like udev does this today if
you look at how udevd works, udevd uses the kernel as the filter to only
wake up processes that have subscribed to specific events.  It's as if
no one actually looks at how this works :(

> For example, in our Android use case, we have no intention of running
> unmodified Android
> inside container and modifying Android's ueventd is not an issue for us.
> Android userspace uses uevents extensively. For example, vold uses uevents to be
> notified of SDCARD insert event and that is just one example.
> We can get around vold and maybe we can get around every other open
> source Android tool
> that make use of uevents, but phone vendors tend to use uevents to communicate
> messages between their drivers and proprietary software and this is
> were we must have
> a way to filter those uevents in the kernel.

If you are going to modify Android, just use udevd and filter things
that way, you can do it today.  Or just modify the tools that Android
uses for listening to uevents.

> You argue that "device is never bound to a namespace" (and that it
> never will be) and I don't disagree with that.

Great, end of discussion :)

> However, as Eric said, the "broadcast everything" logic does not make
> much sense.

Only one thing is listening to these events, put your filter there
(again, just like udevd does today...)

> In a way, the broadcast logic is opposite to your suggestion to modify
> userspace.

Nope, see above.

> In almost every existing implementation of containers, only the root namespace
> owns responsibility for booting the machine and configuring devices, so if all
> containers were running modified userspace, there would have been no need to
> broadcast uevents to all namespaces.

Wonderful, as you said you were going to modify the container
applications, this isn't an issue :)

> At the very least, you should be able to consent with the idea of
> having the broadcast policy decided by userspace.

But it already is, userspace can decide what it wants to do with every
event today.  Again, to sound like a broken record, just like udevd
does.

greg k-h
