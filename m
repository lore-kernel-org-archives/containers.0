From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7] CGroup API: Update cpusets to use cgroup
	structured file API
Date: Mon, 18 Feb 2008 16:43:33 +0530
Message-ID: <20080218111333.GA6333__43517.1374389485$1203333564$gmane$org@balbir.in.ibm.com>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080215204821.778088000@menage.corp.google.com>
	<20080216212901.70fe35ce.pj@sgi.com>
	<47B9560F.3030402@cn.fujitsu.com>
	<47B96805.7070002@linux.vnet.ibm.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47B96805.7070002-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

* Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> [2008-02-18 16:42:05]:

> Li Zefan wrote:
> > Paul Jackson wrote:
> >> Ok ... this would (I suspect, just from code reading, no bytes were
> >> harmed in actual testing of this) have a minor change to how white
> >> space is handled writing integer flags to cpuset files, and a minor
> >> inconstency.
> >>
> >>  1) Existing cpuset code lets you set a flag (e.g. cpu_exclusive) by doing:
> >> 	echo '1 rumplestiltskin' > cpu_exclusive   # same as: echo 1 > cpu_exclusive
> >>     With this patch, that probably fails, EINVAL.
> >>
> >>  2) With this patch, one can write "1" or "1\n" to cpuset integer files, but one
> >>     cannot successfully write "1\r\n" or "1 " or "1 \n".  However, for the cpuset
> >>     control files that take strings, not single integers, one -can- have any mix
> >>     of trailing white space.
> >>
> >> So far as I know, I have no requirement to write rumplestiltskin to cpuset files ;).
> >> So I'm content to let the minor change in (1) pass without further comment.
> >>
> >> I'd like to recommend consideration of the following patch, to address the
> >> minor inconsistency of (2), and to save a few bytes of kernel text space.
> >>
> > 
> > For memory controller, we have to do this:
> > 	echo -n 4m > memory.limit_in_bytes
> > '-n' is necessary. This is another inconsistency..
> 
Hi. Li,
 
I have a similar patch that fixes the inconsistency.
It's attached below. Andrew, could we please consider this patch for -mm


The memory controller has a requirement that while writing values, we need
to use echo -n. This patch fixes the problem and makes the UI more consistent.

Signed-off-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 Documentation/controllers/memory.txt |    8 ++++----
 kernel/res_counter.c                 |    1 +
 2 files changed, 5 insertions(+), 4 deletions(-)

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
+++ linux-2.6.25-rc2-balbir/Documentation/controllers/memory.txt	2008-02-18 16:18:44.000000000 +0530
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
 
@@ -238,7 +238,7 @@ rmdir() if there are no tasks.
 The type of memory accounted by the cgroup can be limited to just
 mapped pages by writing "1" to memory.control_type field
 
-echo -n 1 > memory.control_type
+echo > memory.control_type
 
 5. TODO
 
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
