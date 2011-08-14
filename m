From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] add SA_CLDREBOOT flag
Date: Sun, 14 Aug 2011 19:10:07 +0200
Message-ID: <20110814171007.GA2097__40746.3810676292$1313342034$gmane$org@redhat.com>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<1313094241-3674-2-git-send-email-daniel.lezcano@free.fr>
	<20110814161532.GA30846@redhat.com>
	<20110814183611.05937c96@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110814183611.05937c96-hY15tx4IgV39zxVx7UNMDg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/14, Bruno Pr=E9mont wrote:
>
> On Sun, 14 August 2011 Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On 08/11, Daniel Lezcano wrote:
> > >
> > > Add the SA_CLDREBOOT flag to enable the CLD_REBOOT on SIGCHLD
> > > when a process of a child pid namespace calls the reboot syscall.
> >
> > I doubt this is really useful in general. SIGCHLD doesn't queue,
> > if the parent of init already has the pending SIGCHLD it won't see
> > CLD_REBOOTED anyway. Anyway, you do not need a special helper to
> > fill siginfo.
> >
> > And personally I strongly dislike SA_CLDREBOOT. For what? Imho, this
> > is unnecessary complication. If we want SIGCHLD-on-reboot, just send
> > it unconditionally.
>
> The information that is needed is what options the container did pass
> to sys_reboot().
> Did the container want a reboot or a power-off (or maybe just touch the
> LINUX_REBOOT_CMD_CAD_* status)?
>
> As long as that information can reach parent/reaper of container's init
> the needed functionality should be there.

Sorry, can't understand.

Once again, why do you want SA_CLDREBOOT?

OK, you may be need to pass some info via siginfo (but note that it can
be lost, and you do not need a special helper for that). But why do you
want this hack in sa_flags?

Oleg.
