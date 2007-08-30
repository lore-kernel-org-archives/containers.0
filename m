From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [RFC][PATCH 3/3] Tune caches to be accountable or not
Date: Thu, 30 Aug 2007 13:44:12 +0400
Message-ID: <46D6916C.3070806@openvz.org>
References: <46D68EA6.2010707@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46D68EA6.2010707-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Srivatsa Vaddagiri <vatsa-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKldhl2p70BpVqQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

The /sys/slab/<name>/cache_account attribute controls
whether the cache <name> is to be accounted or not.

For the reasons described in the zeroth letter kmalloc
caches are excluded and are not allowed to be merged.

By default no caches are accountable. Simply make 
 # echo -n "on" >  /sys/slab/<name>cache_account
to turn accounting on. Maybe its better to make it
 # echo -n "1" > ...
?

Other caches can be accountable, but if we turn accounting
on on some cache and this cache is merged with some other,
this "other" will be accountable as well. We can solve this
by disabling of cache merging, but I'd prefer to know
Christoph's opinion first.

Turning the accounting off is possible only when this cache
is empty.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---

 mm/slub.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 130171d..e4f7390 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2684,6 +2773,16 @@ static int slab_unmergeable(struct kmem_
 	if (s->refcount < 0)
 		return 1;
 
+#ifdef CONFIG_CONTAINER_KMEM
+	/*
+	 * many caches that can be accountable are usually merged with
+	 * kmalloc caches, which are disabled for accounting for a while
+	 */
+
+	if (is_kmalloc_cache(s))
+		return 1;
+#endif
+
 	return 0;
 }
 
@@ -3616,6 +3715,45 @@ static ssize_t defrag_ratio_store(struct
 SLAB_ATTR(defrag_ratio);
 #endif
 
+#ifdef CONFIG_CONTAINER_KMEM
+static ssize_t cache_account_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%s\n",
+			s->flags & SLAB_CHARGE ? "on" : "off");
+}
+
+static ssize_t cache_account_store(struct kmem_cache *s,
+		const char *buf, size_t length)
+{
+	if (strncmp(buf, "on", length) == 0) {
+		if (is_kmalloc_cache(s))
+			/*
+			 * cannot just make these caches accountable
+			 */
+			return -EINVAL;
+
+		s->flags |= SLAB_CHARGE;
+		return length;
+	}
+
+	if (strncmp(buf, "off", length) == 0) {
+		if (any_slab_objects(s))
+			/*
+			 * we cannot turn this off because of the
+			 * full slabs cannot be found in this case
+			 */
+			return -EBUSY;
+
+		s->flags &= ~SLAB_CHARGE;
+		return length;
+	}
+
+	return -EINVAL;
+}
+
+SLAB_ATTR(cache_account);
+#endif
+
 static struct attribute * slab_attrs[] = {
 	&slab_size_attr.attr,
 	&object_size_attr.attr,
@@ -3646,6 +3784,9 @@ static struct attribute * slab_attrs[] =
 #ifdef CONFIG_NUMA
 	&defrag_ratio_attr.attr,
 #endif
+#ifdef CONFIG_CONTAINER_KMEM
+	&cache_account_attr.attr,
+#endif
 	NULL
 };
