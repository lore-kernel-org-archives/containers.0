From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/6] Container Freezer: Use cgroup write_string method
Date: Thu, 31 Jul 2008 22:07:05 -0700
Message-ID: <20080801050701.603089371__11494.9300689206$1217568383$gmane$org@us.ibm.com>
References: <20080801050659.924495279@us.ibm.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Use the new cgroup write_string method rather than the raw write method
because it better matches the needs of the freezer cgroup subsystem.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup_freezer.c |   21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

Index: linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
===================================================================
--- linux-2.6.27-rc1-mm1.orig/kernel/cgroup_freezer.c
+++ linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
@@ -29,11 +29,10 @@
 static const char *freezer_state_strs[] = {
 	"RUNNING",
 	"FREEZING",
 	"FROZEN",
 };
-#define STATE_MAX_STRLEN 8
 
 /*
  * State diagram (transition labels in parenthesis):
  *
  *  RUNNING -(FROZEN)-> FREEZING -(FROZEN)-> FROZEN
@@ -278,27 +277,17 @@ out:
 	spin_unlock_irq(&freezer->lock);
 
 	return retval;
 }
 
-static ssize_t freezer_write(struct cgroup *cgroup,
-			     struct cftype *cft,
-			     struct file *file,
-			     const char __user *userbuf,
-			     size_t nbytes, loff_t *unused_ppos)
+static int freezer_write(struct cgroup *cgroup,
+			 struct cftype *cft,
+			 const char *buffer)
 {
-	char buffer[STATE_MAX_STRLEN + 1];
-	int retval = 0;
+	int retval;
 	enum freezer_state goal_state;
 
-	if (nbytes >= PATH_MAX)
-		return -E2BIG;
-	nbytes = min(sizeof(buffer) - 1, nbytes);
-	if (copy_from_user(buffer, userbuf, nbytes))
-		return -EFAULT;
-	buffer[nbytes + 1] = 0; /* nul-terminate */
-	strstrip(buffer); /* remove any trailing whitespace */
 	if (strcmp(buffer, freezer_state_strs[STATE_RUNNING]) == 0)
 		goal_state = STATE_RUNNING;
 	else if (strcmp(buffer, freezer_state_strs[STATE_FROZEN]) == 0)
 		goal_state = STATE_FROZEN;
 	else
@@ -313,11 +302,11 @@ static ssize_t freezer_write(struct cgro
 
 static struct cftype files[] = {
 	{
 		.name = "state",
 		.read_seq_string = freezer_read,
-		.write = freezer_write,
+		.write_string = freezer_write,
 	},
 };
 
 static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
 {

-- 
