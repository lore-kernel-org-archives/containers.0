From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/10] cgroups: Task counter subsystem v8
Date: Mon, 1 Apr 2013 15:03:09 -0700
Message-ID: <20130401220309.GA2487__30908.3977401771$1364853838$gmane$org@htj.dyndns.org>
References: <1328067470-5980-1-git-send-email-fweisbec@gmail.com>
	<CAAAKZwv9=NFmt6xj1KF2va1i6=UCvka0YkmdOY9JNUMHDOWpGw@mail.gmail.com>
	<20130401184617.GB31435@htj.dyndns.org>
	<CAAAKZwvemKDLeuKr6wWMUSVczkRVDZKSzYrXXEMcZ8qvcFR0zQ@mail.gmail.com>
	<20130401202943.GC31435@htj.dyndns.org>
	<CAAAKZwuZwN68vtk1qO08GXB_OnQNVtqqp+v_NQfP27W0P_aWZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAAAKZwuZwN68vtk1qO08GXB_OnQNVtqqp+v_NQfP27W0P_aWZw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Tim.

On Mon, Apr 01, 2013 at 02:02:06PM -0700, Tim Hockin wrote:
> We run dozens of jobs from dozens users on a single machine.  We
> regularly experience users who leak threads, running into the tens of
> thousands.  We are unable to raise the PID_MAX significantly due to
> some bad, but really thoroughly baked-in decisions that were made a
> long time ago.  What we experience on a daily basis is users

Ummmm.... so that's why you guys can't use kernel memory limit? :(

> complaining about getting a "pthread_create(): resource unavailable"
> error because someone on the machine has leaked.
...
> What I really don't understand is why so much push back?  We have this
> nicely structured cgroup system.  Each cgroup controller's code is
> pretty well partitioned - why would we not want more complete
> functionality built around it?  We accept device drivers for the most
> random, useless crap on the assertion that "if you don't need it,
> don't compile it in".  I can think of a half dozen more really useful,
> cool things we can do with cgroups, but I know the pushback will be
> tremendous, and I just don't grok why.

In general, because it adds to maintenance overhead.  e.g. We've been
trying to make all cgroups follow consistent nesting rules.  We're now
almost there with a couple controllers left.  This one would have been
another thing to do, which is fine if it's necessary but if it isn't
we're just adding up work for no good reason.

More importantly, because cgroup is already plagued with so many bad
design decisions - some from core design decisions - e.g. not being
able to actually identify a resource outside of a context of a task.
Others are added on by each controller going out doing whatever it
wants without thinking about how the whole thing would come together
afterwards - e.g. double accounting between cpu and cpuacct,
completely illogical and unusable hierarchy implementations in
anything other than cpu controllers (they're getting better), and so
on.  Right now it's in a state where there's not many things coherent
about it.  Sure, every controller and feature supports the ones their
makers intended them to but when collected together it's just a mess,
which is one of the common complaints against cgroup.

So, no free-for-all, please.

Thanks.

-- 
tejun
