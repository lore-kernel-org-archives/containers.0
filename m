From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: trying to build simple checkpoint/restart recipes
Date: Wed, 8 Dec 2010 08:52:45 -0600
Message-ID: <20101208145245.GB8316@hallyn.com>
References: <20101208045322.GA17602@mail.hallyn.com>
	<20101208055320.GH10470@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101208055320.GH10470-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > So far, so good.  Note that I couldn't use upstart for my init bc upstart
> > uses inotify, which we don't yet checkpoint.  The kernel is compiled without
> 
> Interesting, I didn't know that. What does upstart use inotify for?

Dunno :)  I was quite put out though.

> > There are two issues:
> > 
> > 1. how to re-create the mounts.  Kernel doesn't do it yet.  There
> >    isn't (that I know of) a clean way to hook lxc-restart to do it.
> >    Comments?
> 
> It's incomplete but I think you can save the most important portions of
> a mount namespace with a simple 1-line command:
> 
> lxc-attach -n cr1 cat /proc/self/mountinfo > cr1.mountinfo
> 
> It's incomplete because:
> 
> 	1. It does not adequately address cross-mount-ns bind mounts (IIRC).
> 
> 	2. It won't work for nested containers (though I don't know if
> 		lxc supports this already it's not *too* far fetched
> 		to expect folks will ask for it in the future). We can
> 		extend the hack to deal with this by making a small
> 		change in sys_checkpoint but I can't see how to fix #1
> 		without doing it all in-kernel anyway.

Heck, for these examples I don't mind just having a sort of dummy
fstab file which both the dummy init and restart use.

> The restoration of the mounts is not scriptable however. It involves
> parsing the mountinfo file and coordinating the mounts with those done by
> lxc itself during lxc-restart. I honestly haven't looked at that closely

I'd be fine with requiring some bit of hand-parsing.  But right, even
once we get a list of the mounts to be restored, I don't know of any
good way to get those mounts re-created at the right time.

I suppose I could hack lxc-restart to do it.  But I'm sort of hoping we
can get something less hacked and more true to the 'real' upstream
code.

> enough yet to say how pretty/ugly that'd be but it entails
> modifications to lxc-restart itself. And since #1 above would still
> be an issue I'm not sure it's worth doing it that way.

So do you know of anyone who's been working on re-creation of mounts
in the kernel?  If not, what have you been doing, hand-scripting
all container creation, checkpoint, and restart?

thanks,
-serge
