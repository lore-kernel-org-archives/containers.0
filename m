From: Andrian Nord <nightnord-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [lxc-devel] Shutting down a container?
Date: Sat, 14 Nov 2009 17:46:02 +0300
Message-ID: <20091114144602.GA3053@nord.niifaq.ru>
References: <4AFD9031.6030102@msgid.tls.msk.ru> <4AFD9E29.1030601@free.fr>
	<20091113195229.GA2327@nord.niifaq.ru>
	<4AFE91D9.10309@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AFE91D9.10309-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

containers@ ml, imo, is more kernel-developing. Your questions are about
userspace and they probably should be asked in ml of userspace utilities
you are using (because implementing many of workarounds of current
kernelspace incapabilities is userspace utilities work, and your problem
may be already solved, but in userspace).

On Sat, Nov 14, 2009 at 02:17:45PM +0300, Michael Tokarev wrote:
> Well, I don't quite see the complexity.  sysvinit here is nothing more
> than an equivalent of run-parts.  It's the /etc/init.d/rc (or whatever
> the path is on your distro) shell script who does all the fun stuff,
> init itself basically does nothing but catching SIGCHLD and (re)starting
> whatever is in inittab (which, in this case, should be very limited).
> 
> So I guess that a custom simple init-alike is all that's needed.  The
> main difference is that it should exit when there's no more processes
> running or after some signal (like /dev/initctl, since process with pid=1
> ignores signals).

Yeap, but sysvinit is universal aproach, so if you use it, you may jasu
use common rc system for container's distro and never mind any problems
with initialising etc (writing a good init is not a trivial task, imo).

> For now I'm not worried about how to signal the "guest" to shut down.
> it can be easily done by, say, attaching something to /dev/tty1 and
> sening a command using lxc-console.  Do unix sockets work between a
> container and "host system" ?

Problem is that
a) lxc-console may not work, if you haven't enabled ttys
b) you may have hudrends of containers

Anyway, attaching to tty is also a bad hack, imo, but just least common =)

No, if you are isolating network, unix sockets will also break. There
is a thread about 'af_unix isolation' at lxc-devel ml, check it for
possible (but, sure, not trivial) workaround.

> 
> What does not work for now is the final step.  init process should exit
> but it does not do that and can't be killed from within the container.
> 
> []

As I said before - you should wait for pids of container and lxc-stop it
when all pids except sysvinit are gone. If you are using custom init,
you may change this behaviour (as you are not worried about kernel panic
or init die anymore) and silently quit when all processes are gone.

> By the way, I for one see no reason why pid=1 in a container is special
> when delivering signals or the like.

It's not special. This is normal behaviour of sysvinit, read it's
manpages.

> That again can be done by placing something into container that will
> ping a given address when everything else is done.

Yes, yes, that is. Questing is in some universal approach, that will
work without hacks or assumptions about container's structure =)
