From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH] cgroups: remove duplicate include
Date: Mon, 15 Mar 2010 11:20:24 +0800
Message-ID: <4B9DA778.7080305@cn.fujitsu.com>
References: <4B9DA6E4.4020501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B9DA6E4.4020501@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

commit e6a1105b ("cgroups: subsystem module loading interface")
and commit c50cc752 ("sched, cgroups: Fix module export")
result in duplicate including of module.h

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---

Fix changelog...

---
 kernel/cgroup.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ef909a3..e2769e1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -27,7 +27,6 @@
  */
 
 #include <linux/cgroup.h>
-#include <linux/module.h>
 #include <linux/ctype.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
-- 
1.6.3
