From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 5/6] cgroups: Triger BUG if a bindable subsystem calls
	css_get()
Date: Wed, 15 Dec 2010 17:36:20 +0800
Message-ID: <4D088C14.1080405__29989.4291245893$1292405814$gmane$org@cn.fujitsu.com>
References: <4D088BB5.30903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D088BB5.30903-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

For now unbindable subsystems should not use css_get/put(), so check
this misuse.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |    7 +++++--
 kernel/cgroup.c        |    5 +++++
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 17579b2..e8ad9f1 100644
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
 
@@ -131,6 +133,7 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
 {
 	if (test_bit(CSS_ROOT, &css->flags))
 		return true;
+	BUG_ON(test_bit(CSS_NO_GET, &css->flags));
 	while (!atomic_inc_not_zero(&css->refcnt)) {
 		if (test_bit(CSS_REMOVED, &css->flags))
 			return false;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fa2c5de..d49a459 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -938,6 +938,11 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	atomic_set(&css->refcnt, 1);
 	css->flags = 0;
 	css->id = NULL;
+
+	/* For now, unbindable subsystems should not call css_get/put(). */
+	if (ss->unbindable)
+		set_bit(CSS_NO_GET, &css->flags);
+
 	if (cgrp == dummytop)
 		set_bit(CSS_ROOT, &css->flags);
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
-- 
1.6.3
