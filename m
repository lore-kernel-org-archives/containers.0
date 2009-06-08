From: Srivatsa Vaddagiri <vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Mon, 8 Jun 2009 10:07:06 +0530
Message-ID: <20090608043705.GC16211__23310.812682803$1244436309$gmane$org@in.ibm.com>
References: <20090604053649.GA3701@in.ibm.com>
	<6599ad830906050153i1afd104fqe70f681317349142@mail.gmail.com>
	<20090605113217.GA20786@in.ibm.com>
	<6599ad830906050518t6cd7d477h36a187f2eaf55578@mail.gmail.com>
	<20090607101120.GB16211@in.ibm.com>
	<661de9470906070835l383cd388h67e40a31be07aef6@mail.gmail.com>
Reply-To: vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <661de9470906070835l383cd388h67e40a31be07aef6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Jun 07, 2009 at 09:05:23PM +0530, Balbir Singh wrote:
> > On further thinking, this is not as simple as that. In above example of
> > 5 tasks on 4 CPUs, we could cap each task at a hard limit of 80%
> > (4 CPUs/5 tasks), which is still not sufficient to ensure that each
> > task gets the perfect fairness of 80%! Not just that, hard-limit
> > for a group (on each CPU) will have to be adjusted based on its task
> > distribution. For ex: a group that has a hard-limit of 25% on a 4-cpu
> > system and that has a single task, is entitled to claim a whole CPU. So
> > the per-cpu hard-limit for the group should be 100% on whatever CPU the
> > task is running. This adjustment of per-cpu hard-limit should happen
> > whenever the task distribution of the group across CPUs change - which
> > in theory would require you to monitor every task exit/migration
> > event and readjust limits, making it very complex and high-overhead.
> >
> =

> We already do that for shares right? I mean instead of 25% hard limit,
> if the group had 25% of the shares the same thing would apply - no?

yes and no. we do rebalance shares based on task distribution, but not
upon every task fork/exit/wakeup/migration event. Its done once in a while,
frequent enough to give "decent" fairness!

> > Balbir,
> > =A0 =A0 =A0 =A0I dont think guarantee can be met easily thr' hard-limit=
s in
> > case of CPU resource. Atleast its not as straightforward as in case of
> > memory!
> =

> OK, based on the discussion - leaving implementation issues out,
> speaking of whether it is possible to implement guarantees using
> shares? My answer would be
> =

> 1. Yes - but then the hard limits will prevent you and can cause idle
> times, some of those can be handled in the implementation. There might
> be other fairness and SMP concerns about the accuracy of the fairness,
> thank you for that data.
> 2. We'll update the RFC (second version) with the findings and send it
> out, so that the expectations are clearer
> 3. From what I've read and seen there seems to be no strong objection
> to hard limits, but some reservations (based on 1) about using them
> for guarantees and our RFC will reflect that.
> =

> Do you agree?

Well yes, guarantee is not a good argument for providing hard limits.
Pay-per-use kind of usage would be a better argument IMHO.

- vatsa
