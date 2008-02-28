From: serge@hallyn.com
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Thu, 28 Feb 2008 15:28:35 -0600
Message-ID: <20080228212835.GB1232@vino.hallyn.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932217AbYB1Vbv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Linux Containers <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pavel Emelianov <xemul@openvz.org>, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage@google.com):
> All control files created by cgroup subsystems are given a prefix
> corresponding to their subsystem name. But control files provided by
> cgroups itself have no prefix. Currently that set of files is just
> "tasks", "notify_on_release" and "release_agent", but that set is
> likely to expand in the future. To reduce the risk of clashes, it
> would make sense to prefix these files and any future ones with the
> "cgroup." prefix.
> 
> The only reason that I can see *not* to do this would be for
> compatibility with 2.6.24. Do people think this is a strong enough
> reason to leave the existing names? If distros are planning to ship
> products based on 2.6.24, presumably they'd be adding their own
> patches anyway, so they could add a trivial prefix change patch too.
> (I realise this discussion would have been more useful *before* 2.6.24
> shipped, but I didn't quite get round to it ...)
> 
> A compromise might be to keep "tasks" unprefixed, and say that future
> names get the "cgroup." prefix; in this case I'd be inclined to add
> the prefix to notify_on_release and release_agent on the grounds that
> there's much less chance of breaking anyone with those files since (I
> suspect) they're much less used.
> 
> Note that if you mount a cgroup filesystem with the "noprefix" option,
> which is what the cpuset filesystem wrapper does, no subsystems have
> prefixes, and in this case the "cgroup." prefix wouldn't be used
> either. So this doesn't affect any users that explicitly mount cpusets
> rather than cgroups.
> 
> Thoughts?

To me it seems quite logical that files belonging to the cgroup
subsystem would have no prefix, and I don't see any good reason to
do so.

-serge
