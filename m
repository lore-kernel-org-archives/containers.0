From: sukadev@us.ibm.com
Subject: [RFC][PATCH 1/7]: Propagate error code from devpts_pty_new
Date: Tue, 8 Apr 2008 14:58:18 -0700
Message-ID: <20080408215818.GA9034@us.ibm.com>
References: <20080408215333.GA8799@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756237AbYDHV7q@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080408215333.GA8799@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Containers <containers@lists.osdl.org>, clg@fr.ibm.com, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Subject: [RFC][PATCH 1/7]: Propagate error code from devpts_pty_new

Have ptmx_open() propagate any error code returned by devpts_pty_new()
(which returns either 0 or -ENOMEM anyway).

Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
---
 drivers/char/tty_io.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: 2.6.25-rc8-mm1/drivers/char/tty_io.c
===================================================================
--- 2.6.25-rc8-mm1.orig/drivers/char/tty_io.c	2008-04-07 14:49:56.000000000 -0700
+++ 2.6.25-rc8-mm1/drivers/char/tty_io.c	2008-04-08 09:12:55.000000000 -0700
@@ -2835,8 +2835,8 @@ static int ptmx_open(struct inode *inode
 	filp->private_data = tty;
 	file_move(filp, &tty->tty_files);
 
-	retval = -ENOMEM;
-	if (devpts_pty_new(tty->link))
+	retval = devpts_pty_new(tty->link);
+	if (retval)
 		goto out1;
 
 	check_tty_count(tty, "tty_open");
