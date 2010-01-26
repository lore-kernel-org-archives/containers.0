From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 1/2] cgroups: Fix to return errno in a failure path
Date: Tue, 26 Jan 2010 16:16:44 +0800
Message-ID: <4B5EA4EC.8020700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751977Ab0AZIQe@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

In cgroup_create(), if alloc_css_id() returns failure, the errno
is not propagated to userspace, so mkdir will fail silently.

To trigger this bug, we mount blkio (or memory subsystem), and
create more then 65534 cgroups. (The number of cgroups is limited
to 65535 if a subsystem has use_id == 1)

 # mount -t cgroup -o blkio xxx /mnt
 # for ((i = 0; i < 65534; i++)); do mkdir /mnt/$i; done
 # mkdir /mnt/65534
 (should return ENOSPC)
 #

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 cgroup.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- a/kernel/cgroup.c.orig	2010-01-19 16:37:37.000000000 +0800
+++ a/kernel/cgroup.c	2010-01-19 16:39:07.000000000 +0800
@@ -3279,14 +3279,17 @@ static long cgroup_create(struct cgroup 
 
 	for_each_subsys(root, ss) {
 		struct cgroup_subsys_state *css = ss->create(ss, cgrp);
+
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
 			goto err_destroy;
 		}
 		init_cgroup_css(css, ss, cgrp);
-		if (ss->use_id)
-			if (alloc_css_id(ss, parent, cgrp))
+		if (ss->use_id) {
+			err = alloc_css_id(ss, parent, cgrp);
+			if (err)
 				goto err_destroy;
+		}
 		/* At error, ->destroy() callback has to free assigned ID. */
 	}
 
