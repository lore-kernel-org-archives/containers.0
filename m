From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/9] bio-cgroup controller
Date: Thu, 16 Apr 2009 12:42:36 +0200
Message-ID: <20090416104234.GA6656__6936.69005199826$1239878745$gmane$org@linux>
References: <1239740480-28125-4-git-send-email-righi.andrea@gmail.com>
	<20090415111528.b796519a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090415093716.GA5968@linux>
	<20090415.213850.226770691.ryov@valinux.co.jp>
	<20090415132356.GA19270@linux>
	<20090416085814.8b6d077f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090416085814.8b6d077f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Apr 16, 2009 at 08:58:14AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 15 Apr 2009 15:23:57 +0200
> Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > On Wed, Apr 15, 2009 at 09:38:50PM +0900, Ryo Tsuruta wrote:
> > > Hi Andrea and Kamezawa-san,
> > > 
> > > > Ryo, it would be great if you can look at this and fix/integrate into
> > > > the mainstream bio-cgroup. Otherwise I can try to to schedule this in my
> > > > work.
> > > 
> > > O.K. I'll apply those fixes and post patches as soon as I can.
> > > 
> > 
> > Very good! I've just tested the bio_cgroup_id inclusion in
> > page_cgroup->flags. I'm posting the patch on-top-of my patchset.
> > 
> > If you're interested, it should apply cleanly to the original
> > bio-cgroup, except for the get/put_cgroup_from_page() part.
> > 
> > Thanks,
> > -Andrea
> > ---
> > bio-cgroup: encode bio_cgroup_id in page_cgroup->flags
> > 
> > Encode the bio_cgroup_id into the flags argument of page_cgroup as
> > suggested by Kamezawa.
> > 
> > Lower 16-bits of the flags attribute are used for the actual page_cgroup
> > flags. The rest is reserved to store the bio-cgroup id.
> > 
> > This allows to save 4 bytes (in 32-bit architectures) or 8 bytes (in
> > 64-bit) for each page_cgroup element.
> > 
> > Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  include/linux/biotrack.h    |    2 +-
> >  include/linux/page_cgroup.h |   24 +++++++++++++++++++++---
> >  mm/biotrack.c               |   26 ++++++++++++--------------
> >  3 files changed, 34 insertions(+), 18 deletions(-)
> > 
> > diff --git a/include/linux/biotrack.h b/include/linux/biotrack.h
> > index 25b8810..4bd0242 100644
> > --- a/include/linux/biotrack.h
> > +++ b/include/linux/biotrack.h
> > @@ -28,7 +28,7 @@ struct bio_cgroup {
> >  
> >  static inline void __init_bio_page_cgroup(struct page_cgroup *pc)
> >  {
> > -	pc->bio_cgroup_id = 0;
> > +	page_cgroup_set_bio_id(pc, 0);
> >  }
> >  
> >  extern struct cgroup *get_cgroup_from_page(struct page *page);
> > diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> > index 00a49c5..af780a4 100644
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -16,12 +16,30 @@ struct page_cgroup {
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> >  	struct mem_cgroup *mem_cgroup;
> >  #endif
> > -#ifdef CONFIG_CGROUP_BIO
> > -	int bio_cgroup_id;
> > -#endif
> >  	struct list_head lru;		/* per cgroup LRU list */
> >  };
> >  
> > +#ifdef CONFIG_CGROUP_BIO
> > +/*
> > + * use lower 16 bits for flags and reserve the rest for the bio-cgroup id
> > + */
> > +#define BIO_CGROUP_ID_SHIFT	(16)
> > +#define BIO_CGROUP_ID_BITS (8 * sizeof(unsigned long) - BIO_CGROUP_ID_SHIFT)
> > +
> > +static inline unsigned long page_cgroup_get_bio_id(struct page_cgroup *pc)
> > +{
> > +	return pc->flags >> BIO_CGROUP_ID_SHIFT;
> > +}
> > +
> > +static inline void page_cgroup_set_bio_id(struct page_cgroup *pc,
> > +				unsigned long id)
> > +{
> > +	WARN_ON(id >= (1UL << BIO_CGROUP_ID_BITS));
> > +	pc->flags &= (1UL << BIO_CGROUP_ID_SHIFT) - 1;
> > +	pc->flags |= (unsigned long)(id << BIO_CGROUP_ID_SHIFT);
> > +}
> > +#endif
> > +
> Ah, there is "Lock" bit in pc->flags and above "set" code does read-modify-write
> without lock_page_cgroup().
> 
> Could you use lock_page_cgroup() or cmpxchg ? (or using something magical technique ?)

If I'm not wrong this should guarantee atomicity without using
lock_page_cgroup().

Thanks,
-Andrea
---
bio-cgroup: encode bio_cgroup_id in page_cgroup->flags

Encode the bio_cgroup_id into the flags argument of page_cgroup as
suggested by Kamezawa.

Lower 16 bits (in 32-bit archs) or lower 32 bits (in 64-bit archs) of
the flags attribute are used for the actual page_cgroup flags. The upper
bits are reserved to store the bio-cgroup id.

This allows to save 4 bytes (in 32-bit architectures) or 8 bytes (in
64-bit) for each page_cgroup element.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/page_cgroup.h |   42 +++++++++++++++++++++++++++++++++++++-----
 mm/biotrack.c               |   24 +++++++++++-------------
 2 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index a7249bb..864ad6f 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -16,14 +16,46 @@ struct page_cgroup {
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 	struct mem_cgroup *mem_cgroup;
 #endif
-#ifdef CONFIG_CGROUP_BIO
-	int bio_cgroup_id;
-#endif
-#if defined(CONFIG_CGROUP_MEM_RES_CTLR) || defined(CONFIG_CGROUP_BIO)
 	struct list_head lru;		/* per cgroup LRU list */
-#endif
 };
 
+#ifdef CONFIG_CGROUP_BIO
+/*
+ * Use the lower 16 bits (in 32-bit archs) or lower 32 bits (in 64-bit archs)
+ * of page_cgroup->flags for the actual flags and reserve the rest for the
+ * bio-cgroup id.
+ *
+ * This allows to atomically read and write the bio-cgroup id without using
+ * lock/unlock_page_cgroup().
+ */
+#if defined(CONFIG_64BIT)
+typedef uint32_t bio_cgroup_id_t;
+#elif defined(CONFIG_32BIT)
+typedef uint16_t bio_cgroup_id_t;
+#else
+#error "unsupported architecture"
+#endif
+
+#define BIO_CGROUP_ID_SHIFT	(sizeof(bio_cgroup_id_t) * 8)
+#define BIO_CGROUP_ID_BITS	(sizeof(bio_cgroup_id_t) * 8)
+#define BIO_CGROUP_ID_MASK	((1UL << BIO_CGROUP_ID_BITS) - 1)
+
+static inline unsigned long page_cgroup_get_bio_id(struct page_cgroup *pc)
+{
+	return (pc->flags >> BIO_CGROUP_ID_SHIFT) & BIO_CGROUP_ID_MASK;
+}
+
+static inline void page_cgroup_set_bio_id(struct page_cgroup *pc,
+				unsigned long id)
+{
+	bio_cgroup_id_t *ptr = (bio_cgroup_id_t *)((unsigned char *)&pc->flags +
+					(BIO_CGROUP_ID_SHIFT / 8));
+
+	WARN_ON(id >= (1UL << BIO_CGROUP_ID_BITS));
+	*ptr = (bio_cgroup_id_t)id;
+}
+#endif /* CONFIG_CGROUP_BIO */
+
 void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
 void __init page_cgroup_init(void);
 struct page_cgroup *lookup_page_cgroup(struct page *page);
diff --git a/mm/biotrack.c b/mm/biotrack.c
index d3a35f1..01f83ba 100644
--- a/mm/biotrack.c
+++ b/mm/biotrack.c
@@ -80,7 +80,7 @@ void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
 	if (unlikely(!pc))
 		return;
 
-	pc->bio_cgroup_id = 0;	/* 0: default bio_cgroup id */
+	__init_bio_page_cgroup(pc);
 	if (!mm)
 		return;
 	/*
@@ -93,11 +93,11 @@ void bio_cgroup_set_owner(struct page *page, struct mm_struct *mm)
 		goto out;
 	/*
 	 * css_get(&bio->css) isn't called to increment the reference
-	 * count of this bio_cgroup "biog" so pc->bio_cgroup_id might turn
-	 * invalid even if this page is still active.
-	 * This approach is chosen to minimize the overhead.
+	 * count of this bio_cgroup "biog" so the bio-cgroup id might turn
+	 * invalid even if this page is still active. This approach is chosen
+	 * to minimize the overhead.
 	 */
-	pc->bio_cgroup_id = biog->id;
+	page_cgroup_set_bio_id(pc, biog->id);
 out:
 	rcu_read_unlock();
 }
@@ -110,7 +110,7 @@ void bio_cgroup_reset_owner(struct page *page, struct mm_struct *mm)
 	/*
 	 * A little trick:
 	 * Just call bio_cgroup_set_owner() for pages which are already
-	 * active since the bio_cgroup_id member of page_cgroup can be
+	 * active since the bio-cgroup id member of page_cgroup can be
 	 * updated without any locks. This is because an integer type of
 	 * variable can be set a new value at once on modern cpus.
 	 */
@@ -146,12 +146,10 @@ void bio_cgroup_copy_owner(struct page *npage, struct page *opage)
 	opc = lookup_page_cgroup(opage);
 	if (unlikely(!opc))
 		return;
-
 	/*
-	 * Do this without any locks. The reason is the same as
-	 * bio_cgroup_reset_owner().
+	 * XXX: is it safe to do this without locking?
 	 */
-	npc->bio_cgroup_id = opc->bio_cgroup_id;
+	page_cgroup_set_bio_id(npc, page_cgroup_get_bio_id(opc));
 }
 
 /* Create a new bio-cgroup. */
@@ -248,7 +246,7 @@ struct cgroup *get_cgroup_from_page(struct page *page)
 	if (!pc)
 		return NULL;
 	lock_page_cgroup(pc);
-	biog = find_bio_cgroup(pc->bio_cgroup_id);
+	biog = find_bio_cgroup(page_cgroup_get_bio_id(pc));
 	if (biog) {
 		css_get(&biog->css);
 		cgrp = biog->css.cgroup;
@@ -266,7 +264,7 @@ void put_cgroup_from_page(struct page *page)
 	if (!pc)
 		return;
 	lock_page_cgroup(pc);
-	biog = find_bio_cgroup(pc->bio_cgroup_id);
+	biog = find_bio_cgroup(page_cgroup_get_bio_id(pc));
 	if (biog)
 		css_put(&biog->css);
 	unlock_page_cgroup(pc);
@@ -281,7 +279,7 @@ int get_bio_cgroup_id(struct bio *bio)
 
 	pc = lookup_page_cgroup(page);
 	if (pc)
-		id = pc->bio_cgroup_id;
+		id = page_cgroup_get_bio_id(pc);
 	return id;
 }
 EXPORT_SYMBOL(get_bio_cgroup_id);
