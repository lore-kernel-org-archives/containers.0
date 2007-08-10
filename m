From: xemul@openvz.org
Subject: [PATCH 17/20] Allow signalling container-init
Date: Fri, 10 Aug 2007 15:48:24 +0400
Message-ID: <46BC5088.mailGL71DRY5P@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S937515AbXHJL4b@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@osdl.org
Cc: xemul@openvz.org, devel@openvz.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, oleg@tv-sign.ru, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev@us.ibm.com>

Only the global-init process must be special - any other container-init
process must be killable to prevent run-away processes in the system.

TODO: 	Ideally we should allow killing the container-init only from parent
	container and prevent it being killed from within the container.
	But that is a more complex change and will be addressed by a follow-on
	patch. For now allow the container-init to be terminated by any process
	with sufficient privileges.

Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Acked-by: Pavel Emelyanov <xemul@openvz.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>

---

 signal.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

--- lx26-23-rc1-mm1.orig/kernel/signal.c	2007-08-07 13:52:12.000000000 -0700
+++ lx26-23-rc1-mm1/kernel/signal.c	2007-08-09 17:22:19.000000000 -0700
@@ -1861,11 +1861,9 @@ relock:
 			continue;
 
 		/*
-		 * Init of a pid space gets no signals it doesn't want from
-		 * within that pid space. It can of course get signals from
-		 * its parent pid space.
+		 * Global init gets no signals it doesn't want.
 		 */
-		if (current == task_child_reaper(current))
+		if (is_global_init(current))
 			continue;
 
 		if (sig_kernel_stop(signr)) {
