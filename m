From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/1] checkpoint: define pid==0 as self-checkpoint
Date: Thu, 5 Mar 2009 11:49:51 -0600
Message-ID: <20090305174951.GA9782@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756235AbZCERuO@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

[ this is on top of Dave's version of Oren's patchset, i.e.
http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/daveh/linux-2.6-cr.git;a=shortlog;h=dave-v13.4 ]

Define pid=0 when calling sys_checkpoint as asking for
a self-checkpoint.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/sys.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 4a51ed3..acc5121 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -224,6 +224,8 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
 	if (flags)
 		return -EINVAL;
 
+	if (pid == 0)
+		pid = current->pid;
 	ctx = cr_ctx_alloc(fd, flags | CR_CTX_CKPT);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
-- 
1.5.4.3
