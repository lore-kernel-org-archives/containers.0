From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH][BUGFIX][for -mm] Misc fix for memory cgroup [0/5]
Date: Fri, 12 Oct 2007 01:26:46 +0530
Message-ID: <470E7FFE.6020309@linux.vnet.ibm.com>
References: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071011135345.5d9a4c06.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> This set is a fix for memory cgroup against 2.6.23-rc8-mm2.
> Not including any new feature.
> 
> If this is merged to the next -mm, I'm happy.
> 
> Patches:
> [1/5] ... fix refcnt handling in charge mem_cgroup_charge()
> [2/5] ... fix error handling path in mem_cgroup_charge()
> [3/5] ... check page->cgroup under lock again.
> [4/5] ... fix mem_cgroup_isolate_pages() to skip !PageLRU() pages.
> [5/5] ... fix page migration under memory controller, fixes leak.
> 
> Changes from previous ones.
>  -- dropped new feature.... force_empty patch. It will be posted later.
>  -- fix typos
>  -- added comments
> 
> Tested on x86-64/fake-NUMA system.
> 

I tested the patches, ran kernbench, lmbench and some tests with
parallel containers. Except for the one typo in the page migration
patch, the patches worked quite well. KAMEZAWA-San, could you please
send the updated patch with the compilation fix.

I am yet to test the migration fix (I am yet to get access to a NUMA/
box capable of fake NUMA). I have not measured the performance impact
of these patches.

Andrew, could you please consider these patches for -mm inclusion once
KAMEZAWA-San sends out the fixed migration patch.

> Thanks,
> -Kame
> 
> 
> 
> 
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
