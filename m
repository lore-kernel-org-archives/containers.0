From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 17:00:42 -0800
Message-ID: <6599ad830901271700u43e472dk742992334e456a13__41699.9234854758$1233104670$gmane$org@mail.gmail.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901231515.37442.knikanth@suse.de>
	<alpine.DEB.2.00.0901230223500.15719@chino.kir.corp.google.com>
	<200901232026.16778.knikanth@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200901232026.16778.knikanth-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Nikanth,

On Fri, Jan 23, 2009 at 6:56 AM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
>
> From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
>
> Cgroup based OOM killer controller
>
> Signed-off-by: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
>
> ---
>
> This is a container group based approach to override the oom killer selection
> without losing all the benefits of the current oom killer heuristics and
> oom_adj interface.

The basic functionality looks useful.

But before we add an OOM subsystem and commit to an API that has to be
supported forever, I think it would be good to have an overall design
for what kinds of things we want to be able to do regarding cgroups
and OOM killing.

Specifying a per-cgroup priority is part of the solution, and is
useful for simple cases. Some kind of userspace notification is also
useful.

The notification system that David/Ying posted has worked pretty well
for us at Google - it's allowed us to use cpusets and fake numa to
provide hard memory controls and guarantees for jobs, while avoiding
having jobs getting killed when they expand faster than we expect. But
we also acknowledge that it's a bit of a hack, and it would be nice to
come up with something more generally acceptable for a real
submission.

>
> It adds a tunable oom.victim to the oom cgroup. The oom killer will kill the
> process using the usual badness value but only within the cgroup with the
> maximum value for oom.victim before killing any process from a cgroup with a
> lesser oom.victim number. Oom killing could be disabled by setting
> oom.victim=0.

"priority" might be a better term than "victim".

>
> CPUSET constrained OOM:
> Also the tunable oom.cpuset_constrained when enabled, would disable the
> ordering imposed by this controller for cpuset constrained OOMs.
>
> diff --git a/Documentation/cgroups/oom.txt b/Documentation/cgroups/oom.txt
> new file mode 100644
> index 0000000..772fb41
> --- /dev/null
> +++ b/Documentation/cgroups/oom.txt
> @@ -0,0 +1,34 @@
> +OOM Killer controller
> +--- ------ ----------
> +
> +The OOM killer kills the process based on a set of heuristics such that only

Might be worth adding "theoretically" in this sentence :-)

>        do_posix_clock_monotonic_gettime(&uptime);
> @@ -257,10 +262,30 @@ static struct task_struct *select_bad_process(unsigned
> long *ppoints,
>                        continue;
>
>                points = badness(p, uptime.tv_sec);
> +#ifdef CONFIG_CGROUP_OOM
> +               taskvictim = (container_of(p->cgroups->subsys[oom_subsys_id],
> +                                               struct oom_cgroup, css))->victim;

Firstly, this ought to be using the task_subsys_state() function to
ensure the appropriate rcu_dereference() calls.

Secondly, is it safe? I'm not sure if we're in an RCU section in this
case, and we certainly haven't called task_lock(p) or cgroup_lock().
You should surround this with rcu_read_lock()/rcu_read_unlock().

And thirdly, it would be better to move the #ifdef to the header file,
and provide dummy functions that return 0 for the kill priority if
CONFIG_CGROUP_OOM isn't defined.

> +               honour_cpuset_constraint = *(container_of(p->cgroups-
>>subsys[oom_subsys_id],
> +                                                struct oom_cgroup, css))-
>>cpuset_constraint;

I think that putting this kind of inter-subsystem dependency in is a
bad idea. If you want to control whether the OOM killer treats cpusets
specially, perhaps that flag should be put in cpusets?

> +
> +               if (taskvictim > chosenvictim ||
> +                       (((taskvictim == chosenvictim) ||
> +                               (cpuset_constrained && honour_cpuset_constraint))
> +                                && points > *ppoints) ||
> +                       (taskvictim && !chosen)) {

This could do with more comments or maybe breaking up into simpler conditions.


> +       if (cont->parent == NULL) {
> +               oom_css->victim = 1;

Any reason to default to 1 rather than 0?

> +               oom_css->cpuset_constraint =
> +                       kzalloc(sizeof(*oom_css->cpuset_constraint), GFP_KERNEL);
> +               *oom_css->cpuset_constraint = false;
> +       } else {
> +               parent = oom_css_from_cgroup(cont->parent);
> +               oom_css->victim = parent->victim;
> +               oom_css->cpuset_constraint = parent->cpuset_constraint;
> +       }

So there's a single cpuset_constraint shared by all cgroups? Isn't
that just a global variable then?

> +
> +static int oom_victim_write(struct cgroup *cgrp, struct cftype *cft,
> +                                       u64 val)
> +{
> +
> +        cgroup_lock();

This isn't really doing much, since you don't synchronize on the read
side (either the file handler or in the OOM killer itself). It might
be better to just make the value an atomic_t and avoid taking
cgroup_lock() here.

Should we enforce any constraint that a cgroup can never have a lower
kill priority than its parent? Or a separate "min child priority"
value, or just make the cgroup's priority be the max of any in its
path to the root? That would allow you to safely delegate OOM priority
control to sub cgroups while still controlling relative priorities for
each subtree.

> +static int oom_cpuset_write(struct cgroup *cont, struct cftype *cft,
> +                            const char *buffer)
> +{
> +       if (buffer[0] == '1' && buffer[1] == 0)
> +               *(oom_css_from_cgroup(cont))->cpuset_constraint = true;
> +       else if (buffer[0] == '0' && buffer[1] == 0)
> +               *(oom_css_from_cgroup(cont))->cpuset_constraint = false;
> +       else
> +               return -EINVAL;
> +       return 0;
> +}

This can be a u64 write handler that just complains if its input isn't 0 or 1.

> +static struct cftype oom_cgroup_files[] = {
> +       {
> +               .name = "victim",
> +               .read_u64 = oom_victim_read,
> +               .write_u64 = oom_victim_write,
> +       },
> +};
> +
> +static struct cftype oom_cgroup_root_files[] = {
> +       {
> +               .name = "victim",
> +               .read_u64 = oom_victim_read,
> +               .write_u64 = oom_victim_write,
> +       },

Don't duplicate here - just have disjoint sets of files, and call
cgroup_add_files(oom_cgroup_root_files) in addition to the regular
files if it's the root. (Although as I mentioned above, I don't really
think this is the right place for the cpuset_constraint file)

Paul
