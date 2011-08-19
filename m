From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Fri, 19 Aug 2011 17:24:16 +0200
Message-ID: <20110819152416.GA17034__21371.37797331$1313767880$gmane$org@redhat.com>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>
	<20110815144744.GA9660@redhat.com> <4E4DA461.8030006@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E4DA461.8030006-GANU6spQydw@public.gmane.org>
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

On 08/19, Daniel Lezcano wrote:
>
> On 08/15/2011 04:47 PM, Oleg Nesterov wrote:
> >
> > 	- sys_reboot(cmd) does
> >
> > 		if (!global_namespace) {
> > 			task_active_pid_ns(current)->reboot_cmd = cmd;
> > 			sigkill_my_init();
> > 		}
>
> Hi Oleg,
>
> what would be your advice to get rid of from_ancestor_ns which prevent
> the signal to be delivered to the init process ?

Sure, a plain kill can't work. You can do force_sig_info(), this clears
SIGNAL_UNKILLABLE.

Hmm. But now I seem to recall we have other reasons to make the new
sigkill_task() helper... We will see. Anyway, force_ should work afaics.

Oleg.
