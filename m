From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 0/7] cpuset writeback throttling
Date: Thu, 6 Nov 2008 10:34:55 +0900
Message-ID: <20081106103455.f3277a72.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.0810292337170.23858@chino.kir.corp.google.com>
	<20081104124753.fb1dde5a.akpm@linux-foundation.org>
	<1225831988.7803.1939.camel@twins>
	<20081104131637.68fbe055.akpm@linux-foundation.org>
	<1225833710.7803.1993.camel@twins>
	<20081104135004.f1717fcf.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041601100.5077@quilx.com>
	<20081104143534.b5c16147.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811041648350.6254@quilx.com>
	<20081104153610.bbfd5ed8.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811042036000.31167@quilx.com>
	<20081104190505.769b93ec.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811050747040.11867@quilx.com>
	<20081105104145.abd6fc91.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811051415360.31450@quilx.com>
	<20081105123150.d6628805.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0811051434300.31450@quilx.com>
	<20081105125603.36d0c222.akpm@linux-foundation.org>
	<alpine.DEB.2.00.0811051347240.21365@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754704AbYKFBfp@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0811051347240.21365@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, Christoph Lameter <cl@linux-foundation.org>, dfults@sgi.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Paul Menage <menage@google.com>, Andrea Righi <righi.andrea@gmail.com>
List-Id: containers.vger.kernel.org

On Wed, 5 Nov 2008 14:04:42 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> > So the world wouldn't end if we just didn't merge it.  Those users
> > stick with their workarounds and the kernel remains simpler and
> > smaller.
> > 
> 
> Agreed.  This patchset is admittedly from a different time when cpusets 
> was the only relevant extension that needed to be done.
> 
BTW, what is the problem this patch wants to fix ?
  1. avoid slow-down of memory allocation by triggering write-out earlier.
  2. avoid OOM by throttoling dirty pages.

About 1, memcg's diry_ratio can help if mounted as
   mount -t cgroup none /somewhere/  -o cpuset,memory
(If the user can accept overheads of memcg.)
If implemented.

About 2, A Google guy posted OOM handler cgroup to linux-mm.

> > How do we work out which is the best choice here?  I don't have enough
> > information to do this.
> > 
> 
> If we are to support memcg-specific dirty ratios, that requires the 
> aforementioned statistics to be collected so that the calculation is even 
> possible.  The series at 
> 
> 	http://marc.info/?l=linux-kernel&m=122123225006571
> 	http://marc.info/?l=linux-kernel&m=122123241106902
> 
yes. we(memcg) need this kind of.

> is a step in that direction, although I'd prefer to see NR_UNSTABLE_NFS to 
> be extracted separately from MEM_CGROUP_STAT_FILE_DIRTY so 
> throttle_vm_writeout() can also use the new statistics.
> 
Thank you for input.

Thanks,
-Kame
