From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 4/4] vfs: Add ->statfs callback for pipefs
Date: Mon, 8 Aug 2011 01:22:22 +0400
Message-ID: <20110807212221.GH2080@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akp>
Cc: Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Cyrill Gorcunov <gorcunov@openvz.org>
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>

This is done to make it possible to distinguish pipes
from fifos when opening one via /proc/<pid>/fd/ link.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Reviewed-by: Tejun Heo <tj@kernel.org>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/pipe.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.git/fs/pipe.c
===================================================================
--- linux-2.6.git.orig/fs/pipe.c
+++ linux-2.6.git/fs/pipe.c
@@ -1254,6 +1254,7 @@ out:
 
 static const struct super_operations pipefs_ops = {
 	.destroy_inode = free_inode_nonrcu,
+	.statfs = simple_statfs,
 };
 
 /*
