From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Use same_thread_group() in signalfd.c
Date: Wed, 29 Aug 2007 17:19:48 +0400
Message-ID: <46D57274.3040802@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760290AbXH2NXr@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, Sukadev Bhattiprolu <sukadev@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

This is a lost hunk of previous patch that isolated the
explicit usage of task->tgid in some places. The signalfd
code uses the tsk->tgid comparison.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/signalfd.c b/fs/signalfd.c
index a8e293d..5bfd2c5 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -64,7 +64,7 @@ static int signalfd_lock(struct signalfd
 		return 0;
 	}
 
-	if (lk->tsk->tgid == current->tgid)
+	if (same_thread_group(lk->tsk, current->tgid))
 		lk->tsk = current;
 
 	return 1;
