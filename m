From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Mon, 22 Aug 2011 17:44:48 +0200
Message-ID: <20110822154448.GA8527__27114.3249971376$1314028359$gmane$org@redhat.com>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>
	<20110815144744.GA9660@redhat.com> <4E4DA461.8030006@free.fr>
	<20110819152416.GA17034@redhat.com> <4E524B73.3050704@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E524B73.3050704-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/22, Daniel Lezcano wrote:
>
> If we pass the reason to the exit_code of the init process, that will be
> a bit weird as the process is signaled and did not exited  no ?

Just in case, you shouldn't change ->exit_code blindly. We should only
change it if init was a) SIGKILL'ed and b) pid_ns->reboot_cmd is set.
In this case we can assume that it was killed by sys_reboot.

Now. I didn't really mean exit_state should be equal to sys_reboot's
cmd arg. I thought about something like

	swicth (reboot_cmd) {
	case LINUX_REBOOT_CMD_RESTART:
		code = SIGHUP;
		break;
	case LINUX_REBOOT_CMD_HALT:
		code = SIGINT;	// doesn't really matter what we report
		...
	}

we know that init can't be killed by SIGHUP/SIGINT, and this can't be
confused with the case when init does exit(exit_code).

But in fact I do not not think that WIFSIGNALED() is that important.
init shouldn't exit anyway.

> Furthermore, how to differentiate an application container (eg. a
> script) exiting with an error with the same value of a reboot reason ?

Well, I think it is better to fix the script than the kernel.


Daniel, I am not arguing. I agree that this looks like the hack anyway.
Just I think that other approaches are even worse imho. We should try
to make the kernel change as simple as possible.


> Wouldn't make sense to let the user to specify a signal via prctl where
> the si_code is filled with the reason ?

Sorry, I don't quite understand the idea...

And, iiuc, the point was to "fix" sys_reboot() so that we do not need
to mofify the distro/userspace?



In short. Please do what you like more. But I'd like you to know,
I'll argue with any complications which (afaics!) we can avoid,
I promise ;)

Oleg.
