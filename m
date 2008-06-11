From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: [PATCH 2/2] cryo: minimal test program
Date: Wed, 11 Jun 2008 16:14:10 +0200
Message-ID: <20080611141409.206147277@theryb.frec.bull.fr>
References: <20080611141350.541711754@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

This is the dumb test program I managed to restart after I re-enabled
the checkpointing of thread area stuff.

Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
--
---
 tests/Makefile  |    2 +-
 tests/compute.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

Index: cryodev/tests/Makefile
===================================================================
--- cryodev.orig/tests/Makefile
+++ cryodev/tests/Makefile
@@ -1,4 +1,4 @@
-TARGETS = sleep mksysvipc pause_asm
+TARGETS = sleep mksysvipc pause_asm compute
 
 CFLAGS = -static
 
Index: cryodev/tests/compute.c
===================================================================
--- /dev/null
+++ cryodev/tests/compute.c
@@ -0,0 +1,17 @@
+#include <stdio.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+int main()
+{
+	int i = 0;
+	double f = 0;
+
+	printf("Running as %d\n", getpid());
+	while (i<1000000000) {
+		f = i / 0.000234567;
+		if (i%10000000 == 0)
+			printf("i is %d (pid %d)\n", i, getpid());
+		i++;
+	}
+}

-- 
