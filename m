From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 00/10] cgroups: Task counter subsystem v6
Date: Fri, 4 Nov 2011 11:17:26 -0200
Message-ID: <4EB3E5E6.2060002__19717.2532593415$1320413034$gmane$org@parallels.com>
References: <1317668832-10784-1-git-send-email-fweisbec@gmail.com>
	<20111004150111.e9337268.akpm00@gmail.com>
	<CAAAKZwu67VMiZgdpp=i5p7zyGbOHGHXwF_iprufGPzTLkkUF2A@mail.gmail.com>
	<20111028163021.1ce61f8a.akpm@linux-foundation.org>
	<CAA6-i6o0SPfZJDx4SRR1hY-He0L6zHuv0saH6EaE7Mrc2HF6PA@mail.gmail.com>
	<20111103164917.GF8198@somewhere.redhat.com>
	<4EB2C852.6020706@parallels.com>
	<CALdu-PDY8zpXYM3V9KRk4f2NyGevfNnuaWVdoT-qzSHOK--K3A@mail.gmail.com>
	<4EB2CA03.7030601@parallels.com>
	<CALdu-PA2CDoeUMoNd1y44p_QzphX8J4s6NDcSyVC-rP1HGYwkA@mail.gmail.com>
	<4EB2D0F2.40309@parallels.com>
	<CALdu-PDbJ69FayXSd-kjAMX8AKEroZytPapxsUn8GFsz-z1omQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALdu-PDbJ69FayXSd-kjAMX8AKEroZytPapxsUn8GFsz-z1omQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/03/2011 03:56 PM, Paul Menage wrote:
> On Thu, Nov 3, 2011 at 10:35 AM, Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  wrote:
>>
>>> If multiple subsystems on the same hierarchy each need to
>>> walk up the pointer chain on the same event, then after the first
>>> subsystem has done so the chain will be in cache for any subsequent
>>> walks from other subsystems.
>>
>> No, it won't. Precisely because different subsystems have completely
>> independent pointer chains.
>
> Because they're following res_counter parent pointers, etc, rather
> than using the single cgroups parent pointer chain?

No. Because:

/sys/fs/cgroup/my_subsys/
/sys/fs/cgroup/my_subsys/foo1
/sys/fs/cgroup/my_subsys/foo2
/sys/fs/cgroup/my_subsys/foo1/bar1

and:

/sys/fs/cgroup/my_subsys2/
/sys/fs/cgroup/my_subsys2/foo1
/sys/fs/cgroup/my_subsys2/foo1/bar1
/sys/fs/cgroup/my_subsys2/foo1/bar2

Are completely independent pointer chains. the only thing they share is 
the pointer to the root. And that's irrelevant in the pointer dance.
Also note that I used cpu and cpuacct as an example, and they don't use 
res_counters.

> So if that's the problem, rather than artificially constrain
> flexibility in order to improve micro-benchmarks, why not come up with
> approaches that keep both the flexibility and the performance?

Well, I am not opposed to that even if you happen to agree on what I 
said above. But in the end of the day, with many cgroups appearing, it
may not be about just micro benchmarks.

It is hard to draw the line, but I believe that avoiding creating new 
cgroups subsystems when possible plays in our favor.

Specifically for this one, my arguments are:

* cgroups are a task-grouping entity
* therefore, all cgroups already do some task manipulation in attach/dettach
* all cgroups subsystem already can register a fork handler

Adding a fork limit as a cgroup property seems a logical step to me 
based on that.

If, however, we are really creating this, I think we'd be better of 
referring to this as a "Task Controller" rather than a "Task Counter".

Then at least in the near future when people start trying to limit other 
task-related resources, this can serve as a natural placeholder for 
this. (See the syscall limiting that Lukasz is trying to achieve)

>
> - make res_counter hierarchies be explicitly defined via the cgroup
> parent pointers, rather than an parent pointer hidden inside the
> res_counter. So the cgroup parent chain traversal would all be along
> the common parent pointers (and res_counter would be one pointer
> smaller).
 >
>
> - allow subsystems to specify that they need a small amount of data
> that can be accessed efficiently up the cgroup chain. (Many subsystems
> wouldn't need this, and those that do would likely only need it for a
> subset of their per-cgroup data). Pack this data into as few
> cachelines as possible, allocated as a single lump of memory per
> cgroup. Each subsystem would know where in that allocation its private
> data lay (it would be the same offset for every cgroup, although
> dynamically determined at runtime based on the number of subsystems
> mounted on that hierarchy)
I thought about this second one myself.
I am not yet convinced this would be a win, but I believe there are chances.
