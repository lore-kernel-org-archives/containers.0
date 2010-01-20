From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-test]: fileio1 - Keep logfile open
Date: Wed, 20 Jan 2010 15:09:26 -0800
Message-ID: <20100120230926.GB30288@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 20 Jan 2010 14:31:14 -0800
Subject: [PATCH]: fileio1 - Keep logfile open

In an attempt to close any as-yet uncheckpointable files that are open,
the test case closes all files. But in the process even the log file
(which is checkpointable) is also closed even though the test writes a
lot to the log subsequently.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/fileio1.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fileio/fileio1.c b/fileio/fileio1.c
index efd7c37..e9b468d 100644
--- a/fileio/fileio1.c
+++ b/fileio/fileio1.c
@@ -273,7 +273,10 @@ int main(int argc, char *argv[])
 	 * Cannot checkpoint process with open device files yet;
 	 */
 	printf("Closing stdio fds and writing messages to %s\n", log_fnam);
-	for (i=0; i<100; i++) close(i);
+	for (i=0; i<100; i++)  {
+		if (i != fileno(logfp))
+			close(i);
+	}
 
 	/*
 	 * Announce that we are now prepared for a checkpoint 
-- 
1.6.0.4
