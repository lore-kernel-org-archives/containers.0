From: sukadev@us.ibm.com
Subject: [PATCH 2/3] add do_unshare()
Date: Wed, 9 Apr 2008 15:34:06 -0700
Message-ID: <20080409223406.GB28267@us.ibm.com>
References: <20080409222611.GA28087@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756672AbYDIWff@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080409222611.GA28087@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: clg@fr.ibm.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Subject: [PATCH 2/3] add do_unshare()

This patch adds a do_unshare() routine which will be common
to the unshare() and unshare64() syscall.

Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
---
 kernel/fork.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: 2.6.25-rc2-mm1/kernel/fork.c
===================================================================
--- 2.6.25-rc2-mm1.orig/kernel/fork.c
+++ 2.6.25-rc2-mm1/kernel/fork.c
@@ -1696,7 +1696,7 @@ static int unshare_semundo(u64 unshare_f
  * constructed. Here we are modifying the current, active,
  * task_struct.
  */
-asmlinkage long sys_unshare(unsigned long unshare_flags)
+static long do_unshare(u64 unshare_flags)
 {
 	int err = 0;
 	struct fs_struct *fs, *new_fs = NULL;
@@ -1790,3 +1790,8 @@ bad_unshare_cleanup_thread:
 bad_unshare_out:
 	return err;
 }
+
+asmlinkage long sys_unshare(unsigned long unshare_flags)
+{
+	return do_unshare(unshare_flags);
+}

-- 

--~--~---------~--~----~------------~-------~--~----~
You received this message because you are subscribed to the Google Groups "lxc-dev" group.
To post to this group, send email to lxc-dev@googlegroups.com
To unsubscribe from this group, send email to lxc-dev-unsubscribe@googlegroups.com
For more options, visit this group at http://groups.google.com/group/lxc-dev?hl=en
-~----------~----~----~----~------~----~------~--~---
