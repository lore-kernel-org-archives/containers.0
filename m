From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 4/5] bio-cgroup: Add a cgroup support to dm-ioband
Date: Fri, 19 Sep 2008 20:03:38 +0900 (JST)
Message-ID: <20080919.200338.189705888.ryov__1055.40744630179$1221822373$gmane$org@valinux.co.jp>
References: <20080919.200144.226783261.ryov@valinux.co.jp>
	<20080919.200226.71109122.ryov@valinux.co.jp>
	<20080919.200301.104053955.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080919.200301.104053955.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org
Cc: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

With this patch, dm-ioband can work with the bio cgroup.

Based on 2.6.27-rc1-mm1
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

diff -Ndupr linux-2.6.27-rc1-mm1.cg2/drivers/md/dm-ioband-type.c linux-2.6.27-rc1-mm1.cg3/drivers/md/dm-ioband-type.c
--- linux-2.6.27-rc1-mm1.cg2/drivers/md/dm-ioband-type.c	2008-09-19 10:55:46.000000000 +0900
+++ linux-2.6.27-rc1-mm1.cg3/drivers/md/dm-ioband-type.c	2008-09-19 18:51:00.000000000 +0900
@@ -6,6 +6,7 @@
  * This file is released under the GPL.
  */
 #include <linux/bio.h>
+#include <linux/biocontrol.h>
 #include "dm.h"
 #include "dm-bio-list.h"
 #include "dm-ioband.h"
@@ -53,13 +54,13 @@ static int ioband_node(struct bio *bio)
 
 static int ioband_cgroup(struct bio *bio)
 {
-  /*
-   * This function should return the ID of the cgroup which issued "bio".
-   * The ID of the cgroup which the current process belongs to won't be
-   * suitable ID for this purpose, since some BIOs will be handled by kernel
-   * threads like aio or pdflush on behalf of the process requesting the BIOs.
-   */
-	return 0;	/* not implemented yet */
+	struct io_context *ioc = get_bio_cgroup_iocontext(bio);
+	int id = 0;
+	if (ioc) {
+		id = ioc->id;
+		put_io_context(ioc);
+	}
+	return id;
 }
 
 struct group_type dm_ioband_group_type[] = {
