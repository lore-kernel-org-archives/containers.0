From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Wed, 5 Nov 2008 14:04:42 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0811051347240.21365@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com> <20081104124753.fb1dde5a.akpm@linux-foundation.org> <1225831988.7803.1939.camel@twins> <20081104131637.68fbe055.akpm@linux-foundation.org> <1225833710.7803.1993.camel@twins>
 <20081104135004.f1717fcf.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041601100.5077@quilx.com> <20081104143534.b5c16147.akpm@linux-foundation.org> <Pine.LNX.4.64.0811041648350.6254@quilx.com> <20081104153610.bbfd5ed8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0811042036000.31167@quilx.com> <20081104190505.769b93ec.akpm@linux-foundation.org> <Pine.LNX.4.64.0811050747040.11867@quilx.com> <20081105104145.abd6fc91.akpm@linux-foundation.org> <Pine.LNX.4.64.0811051415360.31450@quilx.com>
 <20081105123150.d6628805.akpm@linux-foundation.org> <Pine.LNX.4.64.0811051434300.31450@quilx.com> <20081105125603.36d0c222.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753028AbYKEWFa@vger.kernel.org>
In-Reply-To: <20081105125603.36d0c222.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, peterz@infradead.org, npiggin@suse.de, Paul Menage <menage@google.com>, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Andrea Righi <righi.andrea@gmail.com>
List-Id: containers.vger.kernel.org

On Wed, 5 Nov 2008, Andrew Morton wrote:

> See, here's my problem: we have a pile of new code which fixes some
> problem.  But the problem seems to be fairly small - it only affects a
> small number of sophisticated users and they already have workarounds
> in place.
> 

The workarounds, while restrictive of how you configure your cpusets, are 
indeed effective.

> So the world wouldn't end if we just didn't merge it.  Those users
> stick with their workarounds and the kernel remains simpler and
> smaller.
> 

Agreed.  This patchset is admittedly from a different time when cpusets 
was the only relevant extension that needed to be done.

> How do we work out which is the best choice here?  I don't have enough
> information to do this.
> 

If we are to support memcg-specific dirty ratios, that requires the 
aforementioned statistics to be collected so that the calculation is even 
possible.  The series at 

	http://marc.info/?l=linux-kernel&m=122123225006571
	http://marc.info/?l=linux-kernel&m=122123241106902

is a step in that direction, although I'd prefer to see NR_UNSTABLE_NFS to 
be extracted separately from MEM_CGROUP_STAT_FILE_DIRTY so 
throttle_vm_writeout() can also use the new statistics.
