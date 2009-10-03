From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] user-cr: Update readme.txt to reflect changed program names
Date: Sat,  3 Oct 2009 00:20:24 -0700
Message-ID: <1254554424-2979-1-git-send-email-matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

ckpt got renamed to checkpoint, rstr got renamed to self_restart,
and mktree got renamed to restart. The readme should reflect this
change in the code.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 readme.txt |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/readme.txt b/readme.txt
index ee5e865..10ccc97 100644
--- a/readme.txt
+++ b/readme.txt
@@ -10,23 +10,23 @@ self.c: a simple program doing self-checkpoint
   running it:
 	$ ./self > out.self
 
-ckpt.c: a program to do external checkpoint of other process(es)
+checkpoint.c: a program to do external checkpoint of other process(es)
   Run with a single argument which is the pid of the target
   process (container init), in the current pid namespace. The
   checkpoint image is written to standard output.
-	$ ./ckpt PID > out.ckpt
+	$ ./checkpoint PID > out.ckpt
 
-rstr.c: a program to restart from a checkpoint of a single process
+self_restart.c: a program to restart from a checkpoint of a single process
   It restarts the process, but does not restore the original pid of
   the process. Redirect standard input from the checkpoint image.
-	$ ./rstr < out.ckpt
+	$ ./self_restart < out.ckpt
 
-mktree.c: a program to restart from a checkpoint of multiple processes
+restart.c: a program to restart from a checkpoint of multiple processes
   It first creates the process tree and then restarts the process. By
   default it does not restore the original pids of the processes (will
   be added in the future). Redirect standard input from the checkpoint
   image.
-	$ ./mktree --no-pids < out.ckpt
+	$ ./restart --no-pids < out.ckpt
 	
 
 TEST PROGRAMS:
-- 
1.5.6.3
