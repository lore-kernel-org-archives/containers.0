From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 00/10] taskstats: Enhancements for precise accounting
Date: Thu, 23 Sep 2010 15:11:39 -0700
Message-ID: <20100923221139.GI23839__5928.86130693859$1285279945$gmane$org@count0.beaverton.ibm.com>
References: <1285249681.1837.28.camel@holzheu-laptop>
	<20100923131136.356075f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100923131136.356075f4.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Shailabh Nagar <nagar1234-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, John stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suresh Siddha <suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 23, 2010 at 01:11:36PM -0700, Andrew Morton wrote:
> On Thu, 23 Sep 2010 15:48:01 +0200
> Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
> > Currently tools like "top" gather the task information by reading procfs
> > files. This has several disadvantages:
> > 

<snip>

> >      3. A new tool "ptop" (precise top) that uses the libraries
> 
> Talk to me about namespaces, please.  A lot of the new code involves
> PIDs, but PIDs are not system-wide unique.  A PID is relative to a PID
> namespace.  Does everything Just Work?  When userspace sends a PID to
> the kernel, that PID is assumed to be within the sending process's PID
> namespace?  If so, then please spell it all out in the changelogs.  If
> not then that is a problem!

Good point.

The pid ought to be valid in the _receiving_ task's pid namespace. That
can be difficult or impossible if we're talking about netlink broadcasts.
In this regard process events connector is an example of what not to do.

> If I can only observe processes in my PID namespace then is that a
> problem?  Should I be allowed to observe another PID namespace's
> processes?  I assume so, because I might be root.  If so, how is that
> to be done?

I don't think even "root" can see/use pids outside its namespace (without
Eric's setns patches). If you want to see all the tasks then rely on root
being able to do stuff in the initial pid namespace. If you really want
to use/know pids in the child pid namespaces then setns is also a
nice solution.

Cheers,
	-Matt Helsley
