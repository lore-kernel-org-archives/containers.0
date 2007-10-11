From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
 cpusets
Date: Thu, 11 Oct 2007 15:03:15 -0700
Message-ID: <20071011150315.78c4f45f.pj@sgi.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	<6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	<20071003105817.7adf6516.pj@sgi.com>
	<6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
	<20071003131632.fed4b848.pj@sgi.com>
	<6599ad830710031331h15d35e90lc63d845efd2de6f5@mail.gmail.com>
	<20071006012437.c0fd3a8a.pj@sgi.com>
	<alpine.DEB.0.9999.0710061047400.24311@chino.kir.corp.google.com>
	<20071006125904.a26ed99f.pj@sgi.com>
	<6599ad830710061409p2dcaa1c8u8c6864beaaafb149@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759470AbXJKWDe@vger.kernel.org>
In-Reply-To: <6599ad830710061409p2dcaa1c8u8c6864beaaafb149@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: rientjes@google.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

Several days ago, Paul M replied to Paul J:
> > Hmmm ... guess I'd have to loop over the cgroup twice, once to count
> > them (the 'count' field is not claimed to be accurate) and then again,
> > after I've kmalloc'd the tasks[] array, filling in the tasks[] array.
> >
> > On a big cgroup on a big system, this could easily be thousands of
> > iteration loops.
> 
> But if userspace has to do it, the effect will be far more expensive.

Ah - but I'm not trying to optimize this particular operation (changing
a cpusets 'cpus').  It's not at all performance critical.

I'm trying to minimize the amount of special purpose code in the
kernel.

The maintenance costs of a line of kernel code are quite a bit higher
than for a line of user code.  I work hard to have most of my lines of
kernel code be on well traveled code paths, of general usefulness, even
if this means that some infrequent operations require yet more user
source code lines and user CPU cycles, in order to be refactored as the
combination of multiple system call primitives.

... all within reasonable limits, of course.

Corner case, special situation, non-trivial chunks of kernel code are
very expensive.  They don't get very good testing coverage in the
real world, and end up harboring latent bugs for months or years,
by which time it can be expensive to deal with them.

Be that as it may, I've just started digesting the actual code
suggestions posted by yourself and David (thanks!) this last week.
I just couldn't resist a bit of philosophizing ... sorry.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
