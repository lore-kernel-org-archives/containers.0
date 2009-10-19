From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] restart: respond to (mimic) signal (if --copy-status asked)
Date: Sun, 18 Oct 2009 22:53:41 -0400
Message-ID: <1255920821-14647-1-git-send-email-orenl@librato.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

In --copy-status mode, the coordinator waits for the restarted
root-task and mimics the way it exits: either by exiting with the same
exit status, or by sending the same fatal signal to self.

In the latter case of the signal, we need to ensure that the default
behavior of that signal is set, or may not kill us.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/restart.c b/restart.c
index cb81293..54da220 100644
--- a/restart.c
+++ b/restart.c
@@ -773,6 +773,7 @@ static int ckpt_parse_status(int status, int mimic, int verbose)
 	if (mimic) {
 		if (sig) {
 			ckpt_dbg("mimic sig %d\n", sig);
+			signal(sig, SIG_DFL);  /* so kill() affects us */
 			kill(_getpid(), sig);
 		} else {
 			ckpt_dbg("mimic ret %d\n", ret);
-- 
1.6.0.4
