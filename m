From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC][PATCH 00/10] taskstats: Enhancements for precise accounting
Date: Fri, 24 Sep 2010 11:50:02 -0700
Message-ID: <20100924115002.fcb4385a.akpm@linux-foundation.org>
References: <1285249681.1837.28.camel@holzheu-laptop>
	<20100923131136.356075f4.akpm@linux-foundation.org>
	<1285319415.2179.116.camel@holzheu-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1285319415.2179.116.camel@holzheu-laptop>
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

On Fri, 24 Sep 2010 11:10:15 +0200
Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> Hello Andrew,
> 
> On Thu, 2010-09-23 at 13:11 -0700, Andrew Morton wrote:
> > > GOALS OF THIS PATCH SET
> > > -----------------------
> > > The intention of this patch set is to provide better support for tools like
> > > top. The goal is to:
> > > 
> > > * provide a task snapshot mechanism where we can get a consistent view of
> > >   all running tasks.
> > > * provide a transport mechanism that does not require a lot of system calls
> > >   and that allows implementing low CPU overhead task monitoring.
> > > * provide microsecond CPU time granularity.
> > 
> > This is a big change!  If this is done right then we're heading in the
> > direction of deprecating the longstanding way in which userspace
> > observes the state of Linux processes and we're recommending that the
> > whole world migrate to taskstats.  I think?
> 
> Or it can be used as alternative. Since procfs has its drawbacks (e.g.
> performance) an alternative could be helpful. 

And it can be harmful.  More kernel code to maintain and test, more
userspace code to develop, maintain, etc.  Less user testing than if
there was a single interface.

> 
> > I worry that there's a dependency on CONFIG_NET?  If so then that's a
> > big problem because in N years time, 99% of the world will be using
> > taskstats, but a few embedded losers will be stuck using (and having to
> > support) the old tools.
> 
> Sure, but if we could add the /proc/taskstats approach, this dependency
> would not be there.

So why do we need to present the same info over netlink?

If the info is available via procfs then userspace code should use that
and not netlink, because that userspace code would also be applicable
to CONFIG_NET=n systems.

> 
> > Does this have the potential to save us from the CONFIG_NET=n problem?
> 
> Yes

Let's say that when it's all tested ;)

> Are PIDs over all namespaces unique?

Nope.  The same pid can be present in different namespaces at the same
time.
