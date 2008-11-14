From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Dynamically allocate struct mem_cgroup_stat_cpu memory
Date: Fri, 14 Nov 2008 13:28:40 +0900
Message-ID: <20081114132840.98d38f12.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081113164201.GV29067@bolzano.suse.de>
	<20081113191837.18ed2ade.akpm@linux-foundation.org>
	<491CF609.3050203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751345AbYKNE3b@vger.kernel.org>
In-Reply-To: <491CF609.3050203@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Blunck <jblunck@suse.de>, containers@lists.osdl.org, Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Fri, 14 Nov 2008 11:52:41 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Andrew Morton wrote:
> > (cc containers@lists.osdl.org)
> > 
> > On Thu, 13 Nov 2008 17:42:01 +0100 Jan Blunck <jblunck@suse.de> wrote:
> > 
> >> When increasing NR_CPUS to 4096 the size of struct mem_cgroup is growing to
> >> 507904 bytes per instance on x86_64. This patch changes the allocation of
> >> struct mem_cgroup_stat_cpu to be based on the number of configured CPUs during
> >> boot time. The init_mem_cgroup still is that huge since it stays statically
> >> allocated and therefore uses the compile-time maximum.
> >>
> 
> I think you can just remove init_mem_cgroup, because memcg doesn't require
> early initialization (when kmalloc is not avaiable), and I found init_mem_cgroup
> is not treated specially after greping 'init_mem_cgroup' in the code.
> 
yes. but if you want to make changes minimum, just leave init_mem_cgroup.cpustat=NULL
and initialize it later. maybe not so difficult.


Thanks,
-Kame
