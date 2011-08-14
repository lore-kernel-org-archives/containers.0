From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH 1/2] add SA_CLDREBOOT flag
Date: Sun, 14 Aug 2011 18:36:11 +0200
Message-ID: <20110814183611.05937c96__44172.3741278567$1313339940$gmane$org@neptune.home>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<1313094241-3674-2-git-send-email-daniel.lezcano@free.fr>
	<20110814161532.GA30846@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110814161532.GA30846-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, 14 August 2011 Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 08/11, Daniel Lezcano wrote:
> >
> > Add the SA_CLDREBOOT flag to enable the CLD_REBOOT on SIGCHLD
> > when a process of a child pid namespace calls the reboot syscall.
> 
> I doubt this is really useful in general. SIGCHLD doesn't queue,
> if the parent of init already has the pending SIGCHLD it won't see
> CLD_REBOOTED anyway. Anyway, you do not need a special helper to
> fill siginfo.
> 
> And personally I strongly dislike SA_CLDREBOOT. For what? Imho, this
> is unnecessary complication. If we want SIGCHLD-on-reboot, just send
> it unconditionally.

The information that is needed is what options the container did pass
to sys_reboot().
Did the container want a reboot or a power-off (or maybe just touch the
LINUX_REBOOT_CMD_CAD_* status)?

As long as that information can reach parent/reaper of container's init
the needed functionality should be there.

Bruno
