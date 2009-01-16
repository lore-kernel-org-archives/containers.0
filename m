From: Matthew Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] NOOP cgroup subsystem
Date: Thu, 15 Jan 2009 18:20:45 -0800
Message-ID: <1232072445.7955.40.camel__13114.0779624277$1232072652$gmane$org@localhost>
References: <20090109143226.b79d21b4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901082226h6d47053cp801dafb67b6e2bc9@mail.gmail.com>
	<20090109153219.dd8c153d.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090109153219.dd8c153d.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-01-09 at 15:32 +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 8 Jan 2009 22:26:46 -0800
> Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > On Thu, Jan 8, 2009 at 9:32 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > >
> > > Motivation: Simply classify Applications by cgroup
> > >  When using cgroup for classifying applications, some kind of "control" or
> > >  "account" subsys must be used. For flexible use of cgroup's nature of
> > >  classifying applications, NOOP is useful. It can be used regardless of
> > >  resource accounting unit or name spaces or some controls.
> > >  IOW, NOOP cgroup allows users to tie PIDs with some nickname.
> > 
> > I agree that the idea is useful. But to me it seems to a bit
> > artificial that you still have to mount some kind of subsystem purely
> > to get the grouping, and that you can only have one such grouping.
> > 
> > I think I'd prefer the ability to mount a cgroups hierarchy without
> > *any* subsystems (maybe with "-o none"?) which would give you a
> > similar effect, but without you needing to know about a special no-op
> > subsystem, and would allow you to have multiple "no-op" groupings.
> > 
> 
> Oh, it seems better idea. Then, we need no configs and no additional subsys.
> Thank you for a hint. I'll check how I can do it.
> 
> Thanks,
> -Kame

	My feeling is this should be a signal subsystem rather than a NOOP
subsystem. Then, if users want the grouping for something besides
signaling, it doesn't matter if they don't issue any signals via the
signal.send file. Also, I think Paul's suggestion would be just as
useful for a signal subsystem.

	What do you think?

Cheers,
	-Matt Helsley

PS: Adding containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org to Cc.
