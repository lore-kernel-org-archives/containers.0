From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Shutting down a container?
Date: Fri, 13 Nov 2009 18:58:01 +0100
Message-ID: <4AFD9E29.1030601@free.fr>
References: <4AFD9031.6030102@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AFD9031.6030102-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LXC Development <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Michael Tokarev wrote:
> What's the supposed way to stop a container?
>
> Let's assume I've a container that's running a complete
> system inside, together with its own init and the like.
> It should clean some stuff when "shutting down", it's
> not wise to kill it right away.  So I run something like
> a shutdown in the container.  And it goes up to `halt'
> and just sits here, with only one process left - it's
> the init process with virtual PID=1, which is reading
> from it's /dev/initctl.
>
> I tried to change /etc/init.d/halt to kill a process with
> pid=1, but that does not work - apparently the signal is
> ignored (even with kill -9) -- ie, init continues as if
> there was no signal.
>
> _But_, when I attempt to run strace on the ("virtual")
> init process, it gets killed with `kill -9' immediately.
>
> It also can be killed (also with -9) from the host system
> regardless of strace.
>
> Should there be some different init perhaps, that will
> exit given some command or signal, instead of sysvinit?
> Or is there other way to shutdown a container?
>
> P.S.  Using debian lenny with 2.6.31.6 kernel and lxc
> utils from yesterdays git.
>   
Unfortunately, it's not supported by the kernel yet.

Random thought : may be it could be interesting to have the kernel to 
send a signal to the init's parent when:

 * LINUX_REBOOT_CMD_POWER_OFF : the parent process kills the pid 1

 * LINUX_REBOOT_CMD_RESTART : the parent process kills the pid 1 and 
relaunch the container

 * LINUX_REBOOT_CMD_HALT: the parent process freeze the container
 
...

may be later:
 * LINUX_REBOOT_CMD_SW_SUSPEND : the parent process checkpoint the container

Well it's just an idea.
