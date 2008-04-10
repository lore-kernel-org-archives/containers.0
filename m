From: Pavel Emelyanov <xemul-3ImXcnM4P+0@public.gmane.org>
Subject: [PATCH 5/10] Bsdacct: make check timer accept an argument
Date: Thu, 10 Apr 2008 12:47:15 +0400
Message-ID: <47FDD413.5040101@sw.ru>
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

We're going to have many bsd_acct_struct instances, not just
one, so the timer (currently working with a global one) has
to know which one to work with.

Use a handy setup_timer macro for it (thanks to Oleg for one).

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 kernel/acct.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/acct.c b/kernel/acct.c
index d9ee183..05f8bc0 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -97,9 +97,10 @@ static struct bsd_acct_struct acct_globals __cacheline_aligned =
 /*
  * Called whenever the timer says to check the free space.
  */
-static void acct_timeout(unsigned long unused)
+static void acct_timeout(unsigned long x)
 {
-	acct_globals.needcheck = 1;
+	struct bsd_acct_struct *acct = (struct bsd_acct_struct *)x;
+	acct->needcheck = 1;
 }
 
 /*
@@ -193,8 +194,8 @@ static void acct_file_reopen(struct file *file)
 		acct_globals.needcheck = 0;
 		acct_globals.active = 1;
 		/* It's been deleted if it was used before so this is safe */
-		init_timer(&acct_globals.timer);
-		acct_globals.timer.function = acct_timeout;
+		setup_timer(&acct_globals.timer, acct_timeout,
+				(unsigned long)&acct_globals);
 		acct_globals.timer.expires = jiffies + ACCT_TIMEOUT*HZ;
 		add_timer(&acct_globals.timer);
 	}
-- 
1.5.3.4
