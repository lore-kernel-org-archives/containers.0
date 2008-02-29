From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Thu, 28 Feb 2008 19:22:32 -0600
Message-ID: <20080228192232.b2211b4d.pj@sgi.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	<20080228173618.139f5bb4.pj@sgi.com>
	<6599ad830802281703hb3cff06r8ba4755f705a0879@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760925AbYB2BWt@vger.kernel.org>
In-Reply-To: <6599ad830802281703hb3cff06r8ba4755f705a0879@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org, akpm@linux-foundation.org
List-Id: containers.vger.kernel.org

> Subsystem-created files already have an appropriate prefix.

Good ... such little consistencies in naming are helpful, when
voluntarily self imposed, without incompatible changes to published
names.

> > No need to
> >  change the existing well known names for this reason.
> 
> But that's part of my point - is it reasonable to describe a system
> that was only introduced in 2.6.24 as "well-known"?

In their earlier cpuset context, "tasks" and "notify_on_release" have
been well known for years.

And breaking actual compatibility, in a way that will break more than
the tiniest set of users, even over one release, should not be done
without both (1) a really good cause, and (2) a plan for migrating
users over a couple of releases to the new interface.

> >  back much earlier than that.  Please don't rename these two files in
> >  cgroups; and of course absolutely don't rename them in cpusets.
> 
> No, I wasn't planning to make any changes to cpusets.

Yeah - I figured you wouldn't risk my wrath changing this in cpusets ;).

Could you please not change them in cgroups, either?

> >  Please don't end up with different names of these files, depending on
> >  whether you're in cgroups or cpusets, either.
> 
> That already happens - when mounted as the "cpuset" filesystem, we
> have names like "mems_allowed". When mounted as cgroups, we have names
> like cpuset.mems_allowed.

Ok - it does make sense that cpuset specific files, when embedded in the
more general purpose cgroups, are adorned with name prefixes that they
didn't have in the legacy API.  And besides, it is what is -- we released
it, and there's no compelling disaster forcing a change.

But generic cgroup infrastructure files, such as "tasks", have not had
such adornments.  And now, that is what it is -- released, and sufficient
to remain as it is.

> No, I don't like that idea either.

Good (and extra credit for saying so with fewer words and more politely
than I managed ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214
