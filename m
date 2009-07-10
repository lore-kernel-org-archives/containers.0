From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [ns_exec] Add SIGCHLD to default clone flags
Date: Fri, 10 Jul 2009 13:52:02 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0907101347460.28818@takamine.ncl.cs.columbia.edu>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


This is the default behavior. Without it, the process will not
report/be reported to the parent on a normal wait() call. Instead
the parent will need to use __WALL wait flag.

This caused a nasty bug where running 'rstr' from a checkpoint
image of a process executed with ns_exec would cause the shell
to skip to the next line in the script without waiting for the
restarted task to terminate, contrary to one's expectation.

TODO: if someone would like to run with anything else than the
SIGCHLD there, then add an option to ns_exec to allow it.

Oren.


diff --git a/ns_exec.c b/ns_exec.c
index 3c3aa9e..0d2f54a 100644
--- a/ns_exec.c
+++ b/ns_exec.c
@@ -219,7 +219,7 @@ void write_pid(char *pid_file, int pid)
 int main(int argc, char *argv[])
 {	
 	int c;
-	unsigned long flags = 0, eflags = 0;
+	unsigned long flags = SIGCHLD, eflags = 0;
 	char ttyname[256];
 	int status;
 	int ret, use_clone = 0;
