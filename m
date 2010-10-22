From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 6/7] cgroups: Warn if a bindable subsystem calls css_get()
Date: Fri, 22 Oct 2010 16:12:06 +0800
Message-ID: <4CC14756.5010504__42463.68739191$1287735348$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC146A4.9090505-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

For now bindable subsystems should not use css_get/put(), so warn
on this misuse.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    7 +++++--
 kernel/cgroup.c        |    3 +++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1e4e1df..10e4e02 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -80,13 +80,15 @@ struct cgroup_subsys_state {
 
 /* bits in struct cgroup_subsys_state flags field */
 enum {
-	CSS_ROOT, /* This CSS is the root of the subsystem */
-	CSS_REMOVED, /* This CSS is dead */
+	CSS_ROOT,	/* This CSS is the root of the subsystem */
+	CSS_REMOVED,	/* This CSS is dead */
+	CSS_NO_GET,	/* Forbid calling css_get/put() */
 };
 
 /* Caller must verify that the css is not for root cgroup */
 static inline void __css_get(struct cgroup_subsys_state *css, int count)
 {
+	BUG_ON(test_bit(CSS_NO_GET, &css->flags));
 	atomic_add(count, &css->refcnt);
 }
 
@@ -119,6 +121,7 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
 {
 	if (test_bit(CSS_ROOT, &css->flags))
 		return true;
+	BUG_ON(test_bit(CSS_NO_GET, &css->flags));
 	while (!atomic_inc_not_zero(&css->refcnt)) {
 		if (test_bit(CSS_REMOVED, &css->flags))
 			return false;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 12c1f7c..88e265d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -936,6 +936,9 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	css->cgroup = cgrp;
 	atomic_set(&css->refcnt, 1);
 	css->flags = 0;
+	/* For now, a bindable subsystem should not call css_get/put(). */
+	if (ss->can_bind)
+		set_bit(CSS_NO_GET, &css->flags);
 	css->id = NULL;
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
-- 
1.7.0.1
