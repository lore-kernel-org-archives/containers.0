From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11381] New: default shmmax
Date: Wed, 20 Aug 2008 12:00:43 -0700
Message-ID: <20080820120043.e6e7e436.akpm@linux-foundation.org>
References: <bug-11381-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755298AbYHTTCH@vger.kernel.org>
In-Reply-To: <bug-11381-10286@http.bugzilla.kernel.org/>
Sender: linux-kernel-owner@vger.kernel.org
To: peter_e@gmx.net
Cc: bugme-daemon@bugzilla.kernel.org, linux-kernel@vger.kernel.org, Nadia Derbey <Nadia.Derbey@bull.net>, Solofo Ramangalahy <Solofo.Ramangalahy@bull.net>, Manfred Spraul <manfred@colorfullife.com>, Pierre Peiffer <peifferp@gmail.com>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 20 Aug 2008 05:58:57 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11381
> 
>            Summary: default shmmax
>            Product: Other
>            Version: 2.5
>      KernelVersion: 2.6.26.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: enhancement
>           Priority: P1
>          Component: Other
>         AssignedTo: other_other@kernel-bugs.osdl.org
>         ReportedBy: peter_e@gmx.net
> 
> 
> I would like to request that the default shmmax setting be increased or the
> downsides of that be documented.  Allow me to explain.
> 
> I am with the PostgreSQL development team.  PostgreSQL is probably one of the
> few users of large amounts of SysV shared memory.  Users would usually want to
> configure anywhere between 10% and 50% of their physical RAM to be used as
> shared memory, which would translate to something on the order of gigabytes
> nowadays.  One of the uniformly annoying things about setting this up is that
> you need to reconfigure the Linux kernel to allow that.  sysctl is nice and
> all, but it still requires users to learn about operating system and kernel
> details, requires root access, and distros don't handle sysctl uniformly
> either.  Maybe there is even a good reason for that, but I couldn't find it,
> and at least I would like to learn it, so that we can pass that information on
> to our users.
> 
> I did some kernel version archeology and found out that up until kernels 2.2
> the shmmax setting appears to have been restricted by CPU-specific constraints,
> as indicated by the default setting being different across CPUs and being
> defined in an asm header.  The default setting on i386 was increased from 16 MB
> to 32 MB somewhere around 1998 in the kernel 2.0 line, and it remains at 32 MB
> in the latest kernel on all architectures.
> 
> Now one question is whether there is a space or time overhead involved with
> setting a high shmmax limit that isn't actually used.  If so, it would be
> interesting to know what that overhead is.  The feeling I get from browsing the
> kernel source code over time is that there was some management overhead and/or
> some restrictions about this in old kernels, but that nowadays it doesn't
> really seem to matter much anymore.  I suspect instead that this whole thing
> was just forgotten, because few applications use large amounts of shared
> memory.
> 
> So, if you want to do us a favor, could you please see about increasing the
> default shmmax setting to whatever the theoretical maximum is?
> 

I don't think anybody has even thought about the shmmax default in
years.  Sure, it might be time to reexamine that.

It would be useful to get distro input on this.  Do they override the
kernel default at boot time?  If so, what do they do?


Also, from a quick read it looks to me that shmmax is busted in the
non-init namespace.

clone_ipc_ns() calls shm_init_ns() which does

	ns->shm_ctlmax = SHMMAX;

which a) fails to inherit the parent's setting and b) cannot be altered
from SHMMAX via the sysctl?
