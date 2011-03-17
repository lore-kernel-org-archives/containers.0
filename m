From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/18] user-cr: Fixup sched.h include
Date: Thu, 17 Mar 2011 10:27:38 -0700
Message-ID: <5a316654b4cc0a18ae05f012ab69b86dbc4b21dd.1300382276.git.matthltc@us.ibm.com>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc@us.ibm.com>
	<1525d5365ced342871277f7a94a42bcd960c04a9.1300382276.git.matthltc@us.ibm.com>
	<ccf68c276e54e7cb9dce0df9b8fec8391dd0e349.1300382276.git.matthltc@us.ibm.com>
	<143894c882d1339322b36ea459531a7debec7f29.1300382276.git.matthltc@us.ibm.com>
	<c9471f79da9f1ddbbbc9d8f565951c2bc5fd5ee7.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c9471f79da9f1ddbbbc9d8f565951c2bc5fd5ee7.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

In file included from restart.c:34:
/opt/crosstool/gcc-4.2.4-glibc-2.3.6/i686-unknown-linux-gnu/lib/gcc/i686-unknown-linux-gnu/4.2.4/../../../../i686-unknown-linux-gnu/sys-include/linux/sched.h:109: error: redefinition of 'struct sched_param'

That include was added in 8fc8b640f8674d6de553cded539d24e08fac6f34
which added some pidns bits using CLONE_NEWPID. Looks like linux/sched.h
was included for this definition but it no longer seems necessary.

The same problem exists in test/ipcshm_multi.c

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c           |    1 -
 test/ipcshm_multi.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/restart.c b/restart.c
index 78d21c0..09e5490 100644
--- a/restart.c
+++ b/restart.c
@@ -34,7 +34,6 @@
 #include <stdarg.h>
 #include <assert.h>
 
-#include <linux/sched.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
diff --git a/test/ipcshm_multi.c b/test/ipcshm_multi.c
index da37feb..98cd82f 100644
--- a/test/ipcshm_multi.c
+++ b/test/ipcshm_multi.c
@@ -7,7 +7,6 @@
 #include <sys/types.h>
 #include <sys/wait.h>
 
-#include <linux/sched.h>
 #include <sched.h>
 
 /* For CLONE_NEWIPC */
-- 
1.6.3.3
