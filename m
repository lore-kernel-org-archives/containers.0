From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] Dynamically allocate struct mem_cgroup_stat_cpu memory
Date: Fri, 14 Nov 2008 11:52:41 +0800
Message-ID: <491CF609.3050203@cn.fujitsu.com>
References: <20081113164201.GV29067@bolzano.suse.de> <20081113191837.18ed2ade.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754358AbYKNDzZ@vger.kernel.org>
In-Reply-To: <20081113191837.18ed2ade.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Blunck <jblunck@suse.de>, containers@lists.osdl.org, Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>

Andrew Morton wrote:
> (cc containers@lists.osdl.org)
> 
> On Thu, 13 Nov 2008 17:42:01 +0100 Jan Blunck <jblunck@suse.de> wrote:
> 
>> When increasing NR_CPUS to 4096 the size of struct mem_cgroup is growing to
>> 507904 bytes per instance on x86_64. This patch changes the allocation of
>> struct mem_cgroup_stat_cpu to be based on the number of configured CPUs during
>> boot time. The init_mem_cgroup still is that huge since it stays statically
>> allocated and therefore uses the compile-time maximum.
>>

I think you can just remove init_mem_cgroup, because memcg doesn't require
early initialization (when kmalloc is not avaiable), and I found init_mem_cgroup
is not treated specially after greping 'init_mem_cgroup' in the code.
