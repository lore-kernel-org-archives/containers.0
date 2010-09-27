From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC][PATCH 00/10] taskstats: Enhancements for precise accounting
Date: Mon, 27 Sep 2010 13:02:56 -0700
Message-ID: <20100927130256.5d9a3db8.akpm__34161.0619718724$1285617942$gmane$org@linux-foundation.org>
References: <1285249681.1837.28.camel@holzheu-laptop>
	<20100923131136.356075f4.akpm@linux-foundation.org>
	<1285319415.2179.116.camel@holzheu-laptop>
	<20100924115002.fcb4385a.akpm@linux-foundation.org>
	<1285579127.2116.62.camel@holzheu-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285579127.2116.62.camel@holzheu-laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Shailabh Nagar <nagar1234-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Thomas-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, John stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Peter-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Suresh Siddha <suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 27 Sep 2010 11:18:47 +0200
Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> Hello Andrew,
> 
> On Fri, 2010-09-24 at 11:50 -0700, Andrew Morton wrote:
> > > > This is a big change!  If this is done right then we're heading in the
> > > > direction of deprecating the longstanding way in which userspace
> > > > observes the state of Linux processes and we're recommending that the
> > > > whole world migrate to taskstats.  I think?
> > > 
> > > Or it can be used as alternative. Since procfs has its drawbacks (e.g.
> > > performance) an alternative could be helpful. 
> > 
> > And it can be harmful.  More kernel code to maintain and test, more
> > userspace code to develop, maintain, etc.  Less user testing than if
> > there was a single interface.
> 
> Sure, the value has to be big enough to justify the effort.
> 
> But as I said, with taskstats and procfs we already have two interfaces
> for getting task information.

That doesn't mean it was the right thing to do!  For the reasons I
outline above, it can be the wrong thing to do and strengthening one of
the alternatives worsens the problem.

> Currently in procfs there is information
> than you can't find in taskstats. But also the other way round in the
> taskstats structure there is very useful information that you can't get
> under proc. E.g. the task delay times, IO accounting, etc.

Sounds like a big screwup ;)

Look at it this way: if you were going to sit down and start to design
a new operating system from scratch, would you design the task status
reporting system as it currently stands in Linux?  Don't think so!

> So currently
> tools have to use both interfaces to get all information, which is not
> optimal.
> 
> > > 
> > > > I worry that there's a dependency on CONFIG_NET?  If so then that's a
> > > > big problem because in N years time, 99% of the world will be using
> > > > taskstats, but a few embedded losers will be stuck using (and having to
> > > > support) the old tools.
> > > 
> > > Sure, but if we could add the /proc/taskstats approach, this dependency
> > > would not be there.
> > 
> > So why do we need to present the same info over netlink?
> 
> Good point. It is not really necessary. I started development using the
> netlink code. Therefore I first added the new command in the netlink
> code. I also thought, it would be a good idea to provide all netlink
> commands over the procfs interface to be consistent.

Maybe we should have delivered taskstats over procfs from day one.
