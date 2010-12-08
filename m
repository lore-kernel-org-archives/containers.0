From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: trying to build simple checkpoint/restart recipes
Date: Wed, 8 Dec 2010 16:26:16 -0600
Message-ID: <20101208222616.GB7952@hallyn.com>
References: <20101208045322.GA17602@mail.hallyn.com>
	<20101208055320.GH10470@count0.beaverton.ibm.com>
	<20101208145245.GB8316@hallyn.com>
	<7E28E74ACE78074AAD1BDD3E455CF8749422@US-EXCH1.sw.swsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7E28E74ACE78074AAD1BDD3E455CF8749422-w6YtkvcGFufufkSEj+1U85Z3qXmFLfmx@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Rob Landley (rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> > > The restoration of the mounts is not scriptable however. It involves
> > > parsing the mountinfo file and coordinating the mounts with those done by
> > > lxc itself during lxc-restart. I honestly haven't looked at that closely
> >
> > I'd be fine with requiring some bit of hand-parsing.  But right, even
> > once we get a list of the mounts to be restored, I don't know of any
> > good way to get those mounts re-created at the right time.
> 
> Mount code is one of my old stomping grounds from back when I wrote
> the busybox mount and switch_root commands and had to learn more
> implementation details about it than I ever wanted to know. :)
> 
> I never could find a proper mount spec, and kept meaning to write one,
> but I blathered about some of the less obvious details here:
> 
>   http://www.mail-archive.com/busybox-9GAsQqxh4YTR7s880joybQ@public.gmane.org/msg07013.html

Bookmarked :)

> There are four top level categories of filesystem:  Block backed, ram backed,
> pipe backed (network and fuse and so on), and synthetic (sysfs, procfs,
> devtmpfs...).  And that's not counting bind mounts (which are internal
> to the VFS and not really a filesystem), and loopback devices (which are
> sort of the _opposite_ of a filesystem)...

Right, for starters handling only bind mounts would be useful.  It's feasible
for userspace to rsync the contents of tmpfs filesystems during checkpoint
and before restart - but it's harder to find the right place for the bind
mounts to get re-attached if done in userspace, because we don't want to
do it too early and risk having mount leaks (so we can't checkpoint later),
and it's hard to coordinate doing it later since someone inside the container
has to do it (unlesss, again, we have leaks - well, or maybe having
MNT_SHARED / for the container would suffice).

> > I suppose I could hack lxc-restart to do it.  But I'm sort of hoping we
> > can get something less hacked and more true to the 'real' upstream
> > code.
> 
> Which upstream code?

Heh, I should have said upstream-destined code.  Referring to
lxc.sf.net and the kernel at www.linux-cr.org.

> > So do you know of anyone who's been working on re-creation of mounts
> > in the kernel?  If not, what have you been doing, hand-scripting
> > all container creation, checkpoint, and restart?
> 
> I express interest in this topic.

Awesome.  Note that we've had lots of prior discussions about the
topic, it's just that we never came to a conclusion, so some fresh
experienced blood would be very helpful.

The last time I went into detail on the topic was at
http://www.mail-archive.com/devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org/msg21418.html
while some older notes on the simpler topics are at
https://ckpt.wiki.kernel.org/index.php/Mounts

thanks,
-serge
