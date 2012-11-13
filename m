From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/17] cgroup: make CSS_* flags bit masks instead of bit
	positions
Date: Mon, 12 Nov 2012 19:01:34 -0800
Message-ID: <1352775704-9023-8-git-send-email-tj@kernel.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Currently, CSS_* flags are defined as bit positions and manipulated
using atomic bitops.  There's no reason to use atomic bitops for them
and bit positions are clunkier to deal with than bit masks.  Make
CSS_* bit masks instead and use the usual C bitwise operators to
access them.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 8 ++++----
 kernel/cgroup.c        | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9dcbfa1..e9f07ef 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -81,7 +81,7 @@ struct cgroup_subsys_state {
 
 /* bits in struct cgroup_subsys_state flags field */
 enum {
-	CSS_ROOT, /* This CSS is the root of the subsystem */
+	CSS_ROOT	= (1 << 0), /* this CSS is the root of the subsystem */
 };
 
 /* Caller must verify that the css is not for root cgroup */
@@ -100,7 +100,7 @@ static inline void __css_get(struct cgroup_subsys_state *css, int count)
 static inline void css_get(struct cgroup_subsys_state *css)
 {
 	/* We don't need to reference count the root state */
-	if (!test_bit(CSS_ROOT, &css->flags))
+	if (!(css->flags & CSS_ROOT))
 		__css_get(css, 1);
 }
 
@@ -113,7 +113,7 @@ static inline void css_get(struct cgroup_subsys_state *css)
 extern bool __css_tryget(struct cgroup_subsys_state *css);
 static inline bool css_tryget(struct cgroup_subsys_state *css)
 {
-	if (test_bit(CSS_ROOT, &css->flags))
+	if (css->flags & CSS_ROOT)
 		return true;
 	return __css_tryget(css);
 }
@@ -126,7 +126,7 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
 extern void __css_put(struct cgroup_subsys_state *css);
 static inline void css_put(struct cgroup_subsys_state *css)
 {
-	if (!test_bit(CSS_ROOT, &css->flags))
+	if (!(css->flags & CSS_ROOT))
 		__css_put(css);
 }
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a91e7ad..d849efd 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4020,7 +4020,7 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	css->flags = 0;
 	css->id = NULL;
 	if (cgrp == dummytop)
-		set_bit(CSS_ROOT, &css->flags);
+		css->flags |= CSS_ROOT;
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
 	cgrp->subsys[ss->subsys_id] = css;
 
-- 
1.7.11.7
