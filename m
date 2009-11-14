From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: [lxc-devel] Shutting down a container?
Date: Sat, 14 Nov 2009 14:17:45 +0300
Message-ID: <4AFE91D9.10309@msgid.tls.msk.ru>
References: <4AFD9031.6030102@msgid.tls.msk.ru> <4AFD9E29.1030601@free.fr>
	<20091113195229.GA2327@nord.niifaq.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091113195229.GA2327-Ad3oKH0rFUpsEo8Uxu2CLw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrian Nord <NightNord-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

[I'm not really sure anymore what's the proper address:
  the question at hand seems to be generic enough for
  containers@]

Andrian Nord wrote:
> On Fri, Nov 13, 2009 at 06:58:01PM +0100, Daniel Lezcano wrote:
>> Michael Tokarev wrote:
>>> Should there be some different init perhaps, that will
>>> exit given some command or signal, instead of sysvinit?
>>> Or is there other way to shutdown a container?
>>>
> 
> There is two techniques, that seems to be 'common':
> 1) Write your own init script, which would run every process you need
> and traping some signal via 'trap' that will exec an shutdown event.
> It has big advantage of lower overhead for rc-subsystem, but much more
> complicated to maintain.

Well, I don't quite see the complexity.  sysvinit here is nothing more
than an equivalent of run-parts.  It's the /etc/init.d/rc (or whatever
the path is on your distro) shell script who does all the fun stuff,
init itself basically does nothing but catching SIGCHLD and (re)starting
whatever is in inittab (which, in this case, should be very limited).

So I guess that a custom simple init-alike is all that's needed.  The
main difference is that it should exit when there's no more processes
running or after some signal (like /dev/initctl, since process with pid=1
ignores signals).

> 2) Second technique is to rewrite container's /etc/inittab of sysvinit
> to have line like that:
> ca:12345:ctrlaltdel:/sbin/shutdown -hP now
> 
> This is, obviously, what init should execute on ctrl-alt-del shortcut,
> actually triggered by SIGINT signal sent to init process.

For now I'm not worried about how to signal the "guest" to shut down.
it can be easily done by, say, attaching something to /dev/tty1 and
sening a command using lxc-console.  Do unix sockets work between a
container and "host system" ?

What does not work for now is the final step.  init process should exit
but it does not do that and can't be killed from within the container.

[]
> This is hack, yes, but there is no common way of inserting commands into
> container by now (there was such thread into lxc-devel maillist), but
> solution is found and needs implementing.

I'll dig there.  But yet again, I'm fine with modifying the container
initscripts or something, the question really is what to do.

By the way, I for one see no reason why pid=1 in a container is special
when delivering signals or the like.

> Much worse situation is with syncing start procedure / waiting for
> network readyness =).

That again can be done by placing something into container that will
ping a given address when everything else is done.

Thanks!

/mjt
