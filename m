From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: How to draw values for /proc/stat
Date: Tue, 6 Dec 2011 09:05:43 +0900
Message-ID: <20111206090543.e72128b6.kamezawa.hiroyu@jp.fujitsu.com>
References: <4EDC8FB1.60407@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EDC8FB1.60407-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 5 Dec 2011 07:32:33 -0200
Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> Hi,
> 
> Specially Peter and Paul, but all the others:
> 
> As you can see in https://lkml.org/lkml/2011/12/4/178, and in my answer 
> to that, there is a question - one I've asked before but without that 
> much of an audience - of whether /proc files read from process living on 
> cgroups should display global or per-cgroup resources.
> 
> In the past, I was arguing for a knob to control that, but I recently 
> started to believe that a knob here will only overcomplicate matters:
> if you live in a cgroup, you should display only the resources you can 
> possibly use. Global is for whoever is in the main cgroup.
> 

Hm. I have a suggestion and a concern.

(A suggestion)
   How about having a mount option for procfs ?
   For example,
	mount -t proc .... -o cgroup_virtualized
   Then, /proc/stat etc shows per-cgroup information.

(A concern)
   /proc/stat will be a mixture of virtualized values and not-virtualized values.
   1. Don't users need to know whether each value is virtualized or not ?
   2. Can we have a way to show "this value is virtualized!" annotation ?


> Now, it comes two questions:
> 1) Do you agree with that, for files like /proc/stat ? I think the most 
> important part is to be consistent inside the system, regardless of what 
> is done
> 
I think some kind of care for users are required as I wrote above.


> 2) Will cpuacct stay? I think if it does, that becomes almost mandatory 
> (at least the bind mount idea is pretty much over here), because drawing 
> value for /proc/stat becomes quite complex.
> The cpuacct cgroup can provide user, sys, etc values. But we also have:
> 

If virtualized /proc/stat works, I don't think 'account only' cgroup is
necessary. It can be obsolete.

Thanks,
-Kame

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
