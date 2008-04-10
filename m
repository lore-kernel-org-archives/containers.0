From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/10] Bsdacct: account task in each namespace is is visible
	from
Date: Thu, 10 Apr 2008 12:59:27 +0400
Message-ID: <47FDD6EF.5050101@openvz.org>
References: <47FDD267.80700@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FDD267.80700-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

This just makes the acct_proces walk the pid namespaces
from current up to the top and account a task in each
with the accounting turned on.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 kernel/acct.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/kernel/acct.c b/kernel/acct.c
index 7fc9f9d..0feba97 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -631,15 +631,9 @@ void acct_collect(long exitcode, int group_dead)
 	spin_unlock_irq(&current->sighand->siglock);
 }
 
-/**
- * acct_process - now just a wrapper around do_acct_process
- *
- * handles process accounting for an exiting task
- */
-void acct_process(void)
+static void acct_process_in_ns(struct pid_namespace *ns)
 {
 	struct file *file = NULL;
-	struct pid_namespace *ns = task_active_pid_ns(current);
 	struct bsd_acct_struct *acct;
 
 	acct = ns->bacct;
@@ -661,3 +655,16 @@ void acct_process(void)
 	do_acct_process(acct, ns, file);
 	fput(file);
 }
+
+/**
+ * acct_process - now just a wrapper around do_acct_process
+ *
+ * handles process accounting for an exiting task
+ */
+void acct_process(void)
+{
+	struct pid_namespace *ns;
+
+	for (ns = task_active_pid_ns(current); ns != NULL; ns = ns->parent)
+		acct_process_in_ns(ns);
+}
-- 
1.5.3.4
