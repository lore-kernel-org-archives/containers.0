From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
Date: Wed, 10 Feb 2010 20:25:31 -0800
Message-ID: <20100211042531.GA8835@us.ibm.com>
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
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 10 Feb 2010 20:09:17 -0800
Subject: [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column

The contianer name is not printed in the lxc-ps output unless the --lxc
option is specified.  But the CONTAINER column is printed (and left
blank) even if the --lxc option is not specified.

	$ /usr/local/bin/lxc-ps -n foo
	CONTAINER    PID TTY          TIME CMD
		   19525 pts/2    00:00:01 bash
		   20311 pts/2    00:00:00 lxc-ps
		   20312 pts/2    00:00:00 ps

Like normal ps, it would be less confusing (IMHO) if the CONTAINER
column is skipped unless the --lxc option is specified.

	$ ./lxc-ps -n foo
	  PID TTY          TIME CMD
	19525 pts/2    00:00:01 bash
	20339 pts/2    00:00:00 lxc-ps
	20340 pts/2    00:00:00 ps

	$ ./lxc-ps --lxc -n foo
	CONTAINER    PID TTY          TIME CMD
	foo        19646 pts/1    00:00:00 lxc-init
	foo        19647 pts/1    00:00:00 bash

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/lxc-ps.in |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/src/lxc/lxc-ps.in b/src/lxc/lxc-ps.in
index 249b104..e1aa655 100755
--- a/src/lxc/lxc-ps.in
+++ b/src/lxc/lxc-ps.in
@@ -124,7 +124,11 @@ sub get_container {
 }
 
 sub display_headers {
-    printf "%-10s %s", "CONTAINER", $PS_HEADERS;
+    if ($LXC_DISPLAY) {
+        printf "%-10s %s", "CONTAINER", $PS_HEADERS;
+    } else {
+        printf "%s", $PS_HEADERS;
+    }
 }
 
 sub display_usage {
@@ -195,7 +199,11 @@ for (@PS_LINES) {
     my $container = get_container $a[$PS_PID_INDEX];
     if ($LXC_DISPLAY == 2 and not $LXC_NAMES{$container}) {next;}
     if ($LXC_DISPLAY == 1 and $container eq '') {next;}
-    printf "%-10s %s", $container, $_;
+    if ($LXC_DISPLAY) {
+        printf "%-10s %s", $container, $_;
+    } else {
+        printf "%s", $_;
+    }
 }
 
 exit 0;
-- 
1.6.6.1
