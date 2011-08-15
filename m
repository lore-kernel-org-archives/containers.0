From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Mon, 15 Aug 2011 16:47:44 +0200
Message-ID: <20110815144744.GA9660__2045.57081820003$1313420009$gmane$org@redhat.com>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110814213642.GB13799-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/14, Serge E. Hallyn wrote:
>
> Quoting Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> > On 08/11, Daniel Lezcano wrote:
> > >
> > > In the case of a VPS, when we shutdown/halt/reboot the container, the
> > > reboot utility will invoke the sys_reboot syscall which has the bad
> > > effect to reboot the host.
> >
> > Stupid question. Can't sys_reboot() simply kill init (and thus the whole
> > pid_ns) in this case?
>
> The goal is to be able to distinguish a request for reboot from shutdown.
> If we just kill the init, then the parent of init (the container monitor)
> cannot restart the container to emulate reboot.

OK, thanks.

What if init reports the reason it was killed?

Ignoring LINUX_REBOOT_CMD_CAD_/etc, I mean, roughly,

	- add "int reboot_cmd" into struct pid_namespace

	- sys_reboot(cmd) does

		if (!global_namespace) {
			task_active_pid_ns(current)->reboot_cmd = cmd;
			sigkill_my_init();
		}

	- change zap_pid_ns_processes() to do

		if (pid_ns->reboot_cmd)	// approximately
			current->exit_state = pid_ns->reboot_cmd;

Then its parent can look at status after wait(&status).


Not that I think this is very nice, but signals are not reliable.
And once again, SIGCHLD doesn't queue. And, perhaps this doesn't
matter, but sys_reboot() sends SIGCHLD and returns -EPERM, this
can confuse the container.


In any case. If you want to send a signal, please do not introduce
SA_CLDREBOOT. Please do not play with ptrace or __wake_up_parent, this
is meaningless. Just fill siginfo and send SIGCHLD unconditionally.

Oleg.
