From: Zhu Yanhai <zhu.yanhai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: How to draw values for /proc/stat
Date: Wed, 7 Dec 2011 22:17:51 +0800
Message-ID: <CAC8teKX7xHK67AJ6pQuTSr4=21FoPkoDL7jfxx-TaGKx5_BFhQ@mail.gmail.com>
References: <4EDC8FB1.60407@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EDC8FB1.60407-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

2011/12/5 Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>:
> Hi,
>
> Specially Peter and Paul, but all the others:
>
> As you can see in https://lkml.org/lkml/2011/12/4/178, and in my answ=
er to
> that, there is a question - one I've asked before but without that mu=
ch of
> an audience - of whether /proc files read from process living on cgro=
ups
> should display global or per-cgroup resources.
>
> In the past, I was arguing for a knob to control that, but I recently
> started to believe that a knob here will only overcomplicate matters:
> if you live in a cgroup, you should display only the resources you ca=
n
> possibly use. Global is for whoever is in the main cgroup.
>
> Now, it comes two questions:
> 1) Do you agree with that, for files like /proc/stat ? I think the mo=
st
> important part is to be consistent inside the system, regardless of w=
hat is
> done
>
> 2) Will cpuacct stay? I think if it does, that becomes almost mandato=
ry (at
> least the bind mount idea is pretty much over here), because drawing =
value
> for /proc/stat becomes quite complex.
> The cpuacct cgroup can provide user, sys, etc values. But we also hav=
e:
>
> * nr_context_switches,
> * jiffies since boot,
> * total_forks,
> * nr_running,
> * nr_iowait,
>
> Now I doubt any of us want to see /proc/stat extended to accommodate =
things
> like nr_context_switches, or even worse, nr_running. The way I see it=
, there
> are two options here:
>
> =C2=A0a) moving everything to cpu cgroup so we keep all values being =
drawn
> =C2=A0 =C2=A0from the same place
> =C2=A0b) Collect that info from multiple places in a transparent way.=
 ctx,
> =C2=A0 =C2=A0nr_running and nr_iowait will probably come from cpu. ji=
ffies can
> =C2=A0 =C2=A0come from wherever, and maybe we can even draw total_for=
ks
> =C2=A0 =C2=A0from Frederic's and avoid counting it twice.
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml

Hi,
I think making /proc files read from process living on cgroups display
per-cgroup resources is a good idea, at least from a common user's
perspective. We are (well, we will) setup a large cluster with
lxc/cgroup for some backend online services in the next months, and
one gap we see is the entries under /proc are not virtualized enough,
especially those performance counters, not only schedule counters
(e.g. /proc/diskstat). Although we can read some numbers in the host
from blkio controller's counters like blkio.io_serviced,
blkio.io_service_time etc, it would be very convenient if the entries
under /proc are virtualized, as we can deploy various existing
maintenance tools directly in the containers, without developing
another monitors. So the over-cost for maintenance can be low.

Let's include lxc-user mailing list for this topic.

--
Thanks,
Zhu Yanhai
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
