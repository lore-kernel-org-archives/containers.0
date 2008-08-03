From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: Per-instance devpts
Date: Sun, 3 Aug 2008 13:04:39 +0100
Message-ID: <20080803130439.743ff0ae@lxorguk.ukuu.org.uk>
References: <20080412172933.GA19295@us.ibm.com>
	<1208027215.28187.17.camel@x61.ebiederm.org>
	<48935205.3090807@zytor.com> <20080803050800.GA4322@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080803050800.GA4322-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

> > 1. /dev/ptmx would have to change to a symlink, ptmx -> pts/ptmx.
> 
> IIRC, /dev/tty also needs a similar symlink.

Making them symlinks is asking for trouble because some code does go
around using stat and the like and tools like MAKEDEV have definite ideas.

For /dev/tty the definition is precisely that it is your controlling
tty. No reference to namespace and a task whose controlling tty is in a
different namespace should still open the controlling tty not some
parallel in another universe when you open /dev/tty.

If you want to make sure the controlling tty is in the right namespace
that can be done in userspace when transferring control into a namespace.
In many cases I doubt that is even what is wanted.

> > 2. Permissions on /dev/ptmx would not be persistent, and would have to
> >    be set via devpts mount options (unless they're 0666 root.tty, which
> >    would presumably be the default.)
> > 3. The /proc/sys/kernel/pty limit would be global; a per-filesystem
> >    limit could be added on top or instead (presumably via a filesystem
> >    mount options.)
> >
> > I worry #1 would have substantial user-space impact, but I don't see a way 
> > around it, since there would be no obvious way to associate /dev/ptmx with 
> > a filesystem.

/dev/tty and /dev/ptmx already primarily operate by identifying a device
and switching the work to that. Actually putting a bit of namespace logic
in the driver code so the actual files stay as expected (device nodes
etc) seems a *lot* simpler than trying to do symlink hacks.

Alan
