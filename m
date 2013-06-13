From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/11] cgroup: clean up css_[try]get() and css_put()
Date: Wed, 12 Jun 2013 21:04:52 -0700
Message-ID: <1371096298-24402-6-git-send-email-tj__8799.06179984591$1371096355$gmane$org@kernel.org>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371096298-24402-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

* __css_get() isn't used by anyone.  Fold it into css_get().

* Add proper function comments to all css reference functions.

This patch is purely cosmetic.

v2: Typo fix as per Li.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h | 48 ++++++++++++++++++++++++------------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 0e32855..a494636 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -94,33 +94,31 @@ enum {
 	CSS_ONLINE	= (1 << 1), /* between ->css_online() and ->css_offline() */
 };
 
-/* Caller must verify that the css is not for root cgroup */
-static inline void __css_get(struct cgroup_subsys_state *css, int count)
-{
-	atomic_add(count, &css->refcnt);
-}
-
-/*
- * Call css_get() to hold a reference on the css; it can be used
- * for a reference obtained via:
- * - an existing ref-counted reference to the css
- * - task->cgroups for a locked task
+/**
+ * css_get - obtain a reference on the specified css
+ * @css: target css
+ *
+ * The caller must already have a reference.
  */
-
 static inline void css_get(struct cgroup_subsys_state *css)
 {
 	/* We don't need to reference count the root state */
 	if (!(css->flags & CSS_ROOT))
-		__css_get(css, 1);
+		atomic_inc(&css->refcnt);
 }
 
-/*
- * Call css_tryget() to take a reference on a css if your existing
- * (known-valid) reference isn't already ref-counted. Returns false if
- * the css has been destroyed.
- */
-
 extern bool __css_tryget(struct cgroup_subsys_state *css);
+
+/**
+ * css_tryget - try to obtain a reference on the specified css
+ * @css: target css
+ *
+ * Obtain a reference on @css if it's alive.  The caller naturally needs to
+ * ensure that @css is accessible but doesn't have to be holding a
+ * reference on it - IOW, RCU protected access is good enough for this
+ * function.  Returns %true if a reference count was successfully obtained;
+ * %false otherwise.
+ */
 static inline bool css_tryget(struct cgroup_subsys_state *css)
 {
 	if (css->flags & CSS_ROOT)
@@ -128,12 +126,14 @@ static inline bool css_tryget(struct cgroup_subsys_state *css)
 	return __css_tryget(css);
 }
 
-/*
- * css_put() should be called to release a reference taken by
- * css_get() or css_tryget()
- */
-
 extern void __css_put(struct cgroup_subsys_state *css);
+
+/**
+ * css_put - put a css reference
+ * @css: target css
+ *
+ * Put a reference obtained via css_get() and css_tryget().
+ */
 static inline void css_put(struct cgroup_subsys_state *css)
 {
 	if (!(css->flags & CSS_ROOT))
-- 
1.8.2.1
