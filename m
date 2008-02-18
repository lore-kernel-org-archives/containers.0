From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7] CGroup API: Update cpusets to use cgroup
	structured file API
Date: Mon, 18 Feb 2008 17:26:25 +0530
Message-ID: <20080218115625.GA406__37636.8743869991$1203336129$gmane$org@balbir.in.ibm.com>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080215204821.778088000@menage.corp.google.com>
	<20080216212901.70fe35ce.pj@sgi.com>
	<47B9560F.3030402@cn.fujitsu.com>
	<47B96805.7070002@linux.vnet.ibm.com>
	<20080218111333.GA6333@balbir.in.ibm.com>
	<jewsp24h3n.fsf@sykes.suse.de>
	<47B971C6.4080807@linux.vnet.ibm.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47B971C6.4080807-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

* Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> [2008-02-18 17:23:42]:

> Andreas Schwab wrote:
> > Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> > 
> >> @@ -238,7 +238,7 @@ rmdir() if there are no tasks.
> >>  The type of memory accounted by the cgroup can be limited to just
> >>  mapped pages by writing "1" to memory.control_type field
> >>  
> >> -echo -n 1 > memory.control_type
> >> +echo > memory.control_type
> > 
> > Looks like you stripped too much here.
> > 
> > Andreas.
> > 
> 
Yikes,

The control type feature documentation needs to go away and Li has a patch for
it, so I'll not touch that part. Here's the updated patch. Thanks for catching
this Andreas.

The memory controller has a requirement that while writing values, we need
to use echo -n. This patch fixes the problem and makes the UI more consistent.

Signed-off-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 Documentation/controllers/memory.txt |    6 +++---
 kernel/res_counter.c                 |    1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-fix-crlf-echo-issue mm/memcontrol.c
diff -puN kernel/res_counter.c~memory-controller-fix-crlf-echo-issue kernel/res_counter.c
--- linux-2.6.25-rc2/kernel/res_counter.c~memory-controller-fix-crlf-echo-issue	2008-02-18 16:15:02.000000000 +0530
+++ linux-2.6.25-rc2-balbir/kernel/res_counter.c	2008-02-18 16:16:16.000000000 +0530
@@ -113,6 +113,7 @@ ssize_t res_counter_write(struct res_cou
 
 	ret = -EINVAL;
 
+	strstrip(buf);
 	if (write_strategy) {
 		if (write_strategy(buf, &tmp)) {
 			goto out_free;
diff -puN Documentation/controllers/memory.txt~memory-controller-fix-crlf-echo-issue Documentation/controllers/memory.txt
--- linux-2.6.25-rc2/Documentation/controllers/memory.txt~memory-controller-fix-crlf-echo-issue	2008-02-18 16:18:26.000000000 +0530
+++ linux-2.6.25-rc2-balbir/Documentation/controllers/memory.txt	2008-02-18 17:24:48.000000000 +0530
@@ -164,7 +164,7 @@ c. Enable CONFIG_CGROUP_MEM_CONT
 
 Since now we're in the 0 cgroup,
 We can alter the memory limit:
-# echo -n 4M > /cgroups/0/memory.limit_in_bytes
+# echo 4M > /cgroups/0/memory.limit_in_bytes
 
 NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
 mega or gigabytes.
@@ -185,7 +185,7 @@ number of factors, such as rounding up t
 availability of memory on the system.  The user is required to re-read
 this file after a write to guarantee the value committed by the kernel.
 
-# echo -n 1 > memory.limit_in_bytes
+# echo 1 > memory.limit_in_bytes
 # cat memory.limit_in_bytes
 4096 Bytes
 
@@ -197,7 +197,7 @@ caches, RSS and Active pages/Inactive pa
 
 The memory.force_empty gives an interface to drop *all* charges by force.
 
-# echo -n 1 > memory.force_empty
+# echo 1 > memory.force_empty
 
 will drop all charges in cgroup. Currently, this is maintained for test.
 
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
