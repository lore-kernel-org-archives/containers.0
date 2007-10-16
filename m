From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] cpuset update_cgroup_cpus_allowed
Date: Mon, 15 Oct 2007 22:12:32 -0700
Message-ID: <6599ad830710152212n646bcepfdebaea0b7fb1678@mail.gmail.com>
References: <20071015071115.16057.72116.sendpatchset@jackhammer.engr.sgi.com>
	 <4713DA85.3020208@google.com> <20071015171636.6213bf43.pj@sgi.com>
	 <471403BF.4090203@google.com> <20071015193439.fe67bc4d.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765814AbXJPFMw@vger.kernel.org>
In-Reply-To: <20071015193439.fe67bc4d.pj@sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: rientjes@google.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, clg@fr.ibm.com, ebiederm@xmission.com, containers@lists.osdl.org, serue@us.ibm.com, svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On 10/15/07, Paul Jackson <pj@sgi.com> wrote:
> > currently against an older kernel
>
> ah .. which older kernel?

2.6.18, but I can do a version against 2.6.23-mm1.

> +       if (!retval) {
> +               cpus_allowed = cpuset_cpus_allowed(p);
> +               if (!cpus_subset(new_mask, cpus_allowed)) {
> +                       /*
> +                        * We must have raced with a concurrent cpuset
> +                        * update. Just reset the cpus_allowed to the
> +                        * cpuset's cpus_allowed
> +                        */
> +                       new_mask = cpus_allowed;
>
> This narrows the race, perhaps sufficiently, but I don't see that it
> guarantees closure.  Memory accesses to two different locations are not
> guaranteed to be ordered across nodes, as best I recall.  The second
> line above, that rereads the cpuset cpus_allowed, could get an old
> value, in essence.
>
>         cpuset update task              sched_setaffinity task
>         ------------------              ----------------------
>
>         A. write cpuset [Q]             V. read cpuset [Q]
>         B. read task [P]                W. check ok
>         C. write task [P]               X. write task [P]
>                                         Y. reread cpuset [Q]
>                                         Z. check ok again
>
> Two memory locations:
>         [P] the cpus_allowed mask in the task_struct of the
>                 task doing the sched_setaffinity call.
>         [Q] the cpus_allowed mask in the cpuset of the cpuset
>                 to which the sched_setaffinity task is attached.
>
> Even though, from the perspective of location [P], both B. and C.
> happened before X., still from the perspective of location [Q] the
> rereading in Y. could return the value the cpuset cpus_allowed had
> before the write in A.  This could result in a task running with
> a cpus_allowed that was totally outside its cpusets cpus_allowed.

But cpuset_cpus_allowed() synchronizes on callback_mutex. So I assert
this race isn't an issue.

>
> I will grant that this is a narrow window.  I won't loose much sleep
> over it.
>
> >  - uses a priority heap to pick the processes to act on, based on start time
>
> This adds a fair bit of code and complexity, relative to my patch.
> This I do loose more sleep over.  There has to be a compelling
> reason for doing this.

My plan was to hide this inside cgroup_iter_* so that users didn't
have to hold the cssgroup_lock across the entire iteration.

>
> The point that David raises, regarding the interaction of this with
> hotplug, seems to be a compelling reason for doing -something-
> different than my patch proposal.
>
> I don't know yet if it compels us to this much code, however.
>
> Any chance you could provide a patch that works against cgroups?
>

Will do - I justed wanted to get this quickly out to show the idea
that I was working on.

Paul
