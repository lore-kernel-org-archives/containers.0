From: sukadev@us.ibm.com
Subject: [PATCH 1/4]: Propagate error code from devpts_pty_new
Date: Sat, 12 Apr 2008 10:32:02 -0700
Message-ID: <20080412173202.GA19449@us.ibm.com>
References: <20080412172933.GA19295@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756415AbYDLRdk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080412172933.GA19295@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: serue@us.ibm.com, matthltc@us.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>, hpa@zytor.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

From: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Subject: [PATCH 1/4]: Propagate error code from devpts_pty_new

Have ptmx_open() propagate any error code returned by devpts_pty_new()
(which returns either 0 or -ENOMEM anyway).

Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
---
 drivers/char/tty_io.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: 2.6.25-rc8-mm1/drivers/char/tty_io.c
===================================================================
--- 2.6.25-rc8-mm1.orig/drivers/char/tty_io.c	2008-04-07 14:49:56.000000000 -0700
+++ 2.6.25-rc8-mm1/drivers/char/tty_io.c	2008-04-09 13:54:00.000000000 -0700
@@ -2835,8 +2835,8 @@ static int ptmx_open(struct inode *inode
 	filp->private_data = tty;
 	file_move(filp, &tty->tty_files);
 
-	retval = -ENOMEM;
-	if (devpts_pty_new(tty->link))
+	retval = devpts_pty_new(tty->link);
+	if (retval)
 		goto out1;
 
 	check_tty_count(tty, "tty_open");
