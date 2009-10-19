From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr] return, don't exist, at coord error
Date: Sun, 18 Oct 2009 21:29:42 -0500
Message-ID: <20091019022942.GA21306@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

All right I can't explain it at the moment, but exit(1) at
ckpt_coordinator() (on error) causes restart.c to exit with 0,
whereas return(ret) causes it to correctly exit with -1.

Without this, a restart whose kernel portion ends with say
-1 ends up returning from user-cr/restart.c with 0, so userspace
can't tell whether sys_restart succeeded or failed.  With the
patch, it fails correctly.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index e6e72ac..87899ba 100644
--- a/restart.c
+++ b/restart.c
@@ -933,7 +933,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 		perror("restart failed");
 		ckpt_verbose("Failed\n");
 		ckpt_dbg("restart failed ?\n");
-		exit(1);
+		return ret;
 	}
 
 	ckpt_verbose("Success\n");
-- 
1.6.1.1
