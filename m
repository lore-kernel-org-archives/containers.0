From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 11:41:56 +0530
Message-ID: <200901221141.57374.knikanth__39696.8353809372$1232605197$gmane$org@suse.de>
References: <200901211638.23101.knikanth@suse.de>
	<200901221043.13684.knikanth@suse.de>
	<20090122142721.34068fdf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090122142721.34068fdf.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?iso-8859-1?q?Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 22 January 2009 10:57:21 KAMEZAWA Hiroyuki wrote:
> On Thu, 22 Jan 2009 10:43:12 +0530
>
> Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
> > On Thursday 22 January 2009 08:58:43 KAMEZAWA Hiroyuki wrote:
> > > On Wed, 21 Jan 2009 16:38:21 +0530
> > >
> > > Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
> > > > As Alan Cox suggested/wondered in this thread,
> > > > http://lkml.org/lkml/2009/1/12/235 , this is a container group based
> > > > approach to override the oom killer selection without losing all the
> > > > benefits of the current oom killer heuristics and oom_adj interface.
> > > >
> > > > It adds a tunable oom.victim to the oom cgroup. The oom killer will
> > > > kill the process using the usual badness value but only within the
> > > > cgroup with the maximum value for oom.victim before killing any
> > > > process from a cgroup with a lesser oom.victim number. Oom killing
> > > > could be disabled by setting oom.victim=0.
> > > >
> > > > Signed-off-by: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
> > >
> > > Assume following
> > >   - the usar can tell "which process should be killed at first"
> > >
> > > What is the difference between oom_adj and this cgroup to users ?
> >
> > It is next to impossible to specify the order among say 10 memory hogging
> > tasks using oom_adj. Using this oom-controller users can specify the
> > exact order.
> >
> > > If oom_adj is hard to use, making it simpler is a good way, I think.
> > > rather than adding new complication.
> > >
> > > It seems both of oom_adj and this cgroup will be hard-to-use functions
> > > for usual system administrators. But no better idea than using memcg
> > > and committing memory usage.
> >
> > To use oom_adj effectively one should continuously monitor oom_score of
> > all the processes, which is a complex moving target and keep on adjusting
> > the oom_adj of many tasks which still cannot guarantee the order. This
> > controller is deterministic and hence easier to use.
>
> Okay, thank you for explanation :)
> I think it's better to explain "why this is much easier to use rather
> than oom_adj and what is the benefit to users." in your patch description
> and to improve your documentation.
>
> +But it is very difficult to suggest an order among tasks to be killed
> during +Out Of Memory situation. The OOM Killer controller aids in doing
> that.
>
> As.
>  Difference from oom_adj:
>  This allows users to specify "strict order" of oom-kill's
> select-bad-process operation. While oom_adj just works as a hint for the
> kernel, OOM Killer Controller gives users full control.
>
>  In general, it's very hard to specify oom-kill order of several
> applications only by oom_adj because it's just affects "badness"
> calculation.
>

Yes, this could be added to the patch description or the documentation.

Thanks
Nikanth
