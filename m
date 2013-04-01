From: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/10] cgroups: Task counter subsystem v8
Date: Mon, 1 Apr 2013 14:02:06 -0700
Message-ID: <CAAAKZwuZwN68vtk1qO08GXB_OnQNVtqqp+v_NQfP27W0P_aWZw__8773.32716850123$1364850181$gmane$org@mail.gmail.com>
References: <1328067470-5980-1-git-send-email-fweisbec@gmail.com>
	<CAAAKZwv9=NFmt6xj1KF2va1i6=UCvka0YkmdOY9JNUMHDOWpGw@mail.gmail.com>
	<20130401184617.GB31435@htj.dyndns.org>
	<CAAAKZwvemKDLeuKr6wWMUSVczkRVDZKSzYrXXEMcZ8qvcFR0zQ@mail.gmail.com>
	<20130401202943.GC31435@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130401202943.GC31435-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Apr 1, 2013 at 1:29 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Mon, Apr 01, 2013 at 01:09:09PM -0700, Tim Hockin wrote:
>> Pardon my ignorance, but... what?  Use kernel memory limits as a proxy
>> for process/thread counts?  That sounds terrible - I hope I am
>
> Well, the argument was that process / thread counts were a poor and
> unnecessary proxy for kernel memory consumption limit.  IIRC, Johannes
> put it as (I'm paraphrasing) "you can't go to Fry's and buy 4k thread
> worth of component".
>
>> misunderstanding?  This task counter patch had several properties that
>> mapped very well to what we want.
>>
>> Is it dead in the water?
>
> After some discussion, Frederic agreed that at least his use case can
> be served well by kmemcg, maybe even better - IIRC it was container
> fork bomb scenario, so you'll have to argue your way in why kmemcg
> isn't a suitable solution for your use case if you wanna revive this.

We run dozens of jobs from dozens users on a single machine.  We
regularly experience users who leak threads, running into the tens of
thousands.  We are unable to raise the PID_MAX significantly due to
some bad, but really thoroughly baked-in decisions that were made a
long time ago.  What we experience on a daily basis is users
complaining about getting a "pthread_create(): resource unavailable"
error because someone on the machine has leaked.

Today we use RLIMIT_NPROC to lock most users down to a smaller max.
But this is a per-user setting, not a per-container setting, and users
do not control where their jobs land.  Scheduling decisions often put
multiple thread-heavy but non-leaking jobs from one user onto the same
machine, which again causes problems.  Further, it does not help for
some of our use cases where a logical job can run as multiple UIDs for
different processes within.

From the end-user point of view this is an isolation leak which is
totally non-deterministic for them.  They can not know what to plan
for.  Getting cgroup-level control of this limit is important for a
saner SLA for our users.

In addition, the behavior around locking-out new tasks seems like a
nice way to simplify and clean up end-life work for the administrative
system.  Admittedly, we can mostly work around this with freezer
instead.

What I really don't understand is why so much push back?  We have this
nicely structured cgroup system.  Each cgroup controller's code is
pretty well partitioned - why would we not want more complete
functionality built around it?  We accept device drivers for the most
random, useless crap on the assertion that "if you don't need it,
don't compile it in".  I can think of a half dozen more really useful,
cool things we can do with cgroups, but I know the pushback will be
tremendous, and I just don't grok why.

Tim
