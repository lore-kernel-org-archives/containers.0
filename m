From: Paul Menage <menage@google.com>
Subject: [PATCH 28/33] memory controller add per container lru and reclaim v7 fix
Date: Mon, 17 Sep 2007 14:03:35 -0700
Message-ID: <20070917210430.675805000@menage.corp.google.com>
References: <20070917210307.116234000@menage.corp.google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760134AbXIQVIn@vger.kernel.org>
Content-Disposition: inline; filename=memory-controller-add-per-container-lru-and-reclaim-v7-fix.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linuxfoundation.org, balbir@linux.vnet.ibm.com, "Serge E. Hallyn" <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, pj@sgi.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
(container->cgroup renaming by Paul Menage <menage@google.com>)

mm/memcontrol.c: In function 'mem_cgroup_charge':
mm/memcontrol.c:337: error: implicit declaration of function 'congestion_wait'

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Paul Menage <menage@google.com>
---

 mm/memcontrol.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN mm/memcontrol.c~memory-controller-add-per-cgroup-lru-and-reclaim-v7-fix mm/memcontrol.c
--- a/mm/memcontrol.c~memory-controller-add-per-cgroup-lru-and-reclaim-v7-fix
+++ a/mm/memcontrol.c
@@ -22,6 +22,7 @@
 #include <linux/cgroup.h>
 #include <linux/mm.h>
 #include <linux/page-flags.h>
+#include <linux/backing-dev.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rcupdate.h>
 #include <linux/swap.h>
_

--
