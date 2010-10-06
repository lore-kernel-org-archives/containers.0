From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] memcg: per cgroup dirty page accounting
Date: Wed, 6 Oct 2010 08:53:10 +0530
Message-ID: <20101006032310.GU7896@balbir.in.ibm.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1286175485-30643-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-Id: containers.vger.kernel.org

* Greg Thelen <gthelen@google.com> [2010-10-03 23:57:55]:

> This patch set provides the ability for each cgroup to have independent dirty
> page limits.
> 
> Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> not be able to consume more than their designated share of dirty pages and will
> be forced to perform write-out if they cross that limit.
> 
> These patches were developed and tested on mmotm 2010-09-28-16-13.  The patches
> are based on a series proposed by Andrea Righi in Mar 2010.
> 
> Overview:
> - Add page_cgroup flags to record when pages are dirty, in writeback, or nfs
>   unstable.
> - Extend mem_cgroup to record the total number of pages in each of the 
>   interesting dirty states (dirty, writeback, unstable_nfs).  
> - Add dirty parameters similar to the system-wide  /proc/sys/vm/dirty_*
>   limits to mem_cgroup.  The mem_cgroup dirty parameters are accessible
>   via cgroupfs control files.
> - Consider both system and per-memcg dirty limits in page writeback when
>   deciding to queue background writeback or block for foreground writeback.
> 
> Known shortcomings:
> - When a cgroup dirty limit is exceeded, then bdi writeback is employed to
>   writeback dirty inodes.  Bdi writeback considers inodes from any cgroup, not
>   just inodes contributing dirty pages to the cgroup exceeding its limit.  
> 
> Performance measurements:
> - kernel builds are unaffected unless run with a small dirty limit.
> - all data collected with CONFIG_CGROUP_MEM_RES_CTLR=y.
> - dd has three data points (in secs) for three data sizes (100M, 200M, and 1G).  
>   As expected, dd slows when it exceed its cgroup dirty limit.
> 
>                kernel_build          dd
> mmotm             2:37        0.18, 0.38, 1.65
>   root_memcg
> 
> mmotm             2:37        0.18, 0.35, 1.66
>   non-root_memcg
> 
> mmotm+patches     2:37        0.18, 0.35, 1.68
>   root_memcg
> 
> mmotm+patches     2:37        0.19, 0.35, 1.69
>   non-root_memcg
> 
> mmotm+patches     2:37        0.19, 2.34, 22.82
>   non-root_memcg
>   150 MiB memcg dirty limit
> 
> mmotm+patches     3:58        1.71, 3.38, 17.33
>   non-root_memcg
>   1 MiB memcg dirty limit
>

Greg, could you please try the parallel page fault test. Could you
look at commit 0c3e73e84fe3f64cf1c2e8bb4e91e8901cbcdc38 and
569b846df54ffb2827b83ce3244c5f032394cba4 for examples. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
