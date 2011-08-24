From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH resend] vfs: Add ->statfs callback for pipefs
Date: Wed, 24 Aug 2011 12:09:24 +0400
Message-ID: <20110824080924.GG29452@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>
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

Any objections to this one? It was a part of a patchset
but can be treated independently so I'm re-sending it alone.

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
