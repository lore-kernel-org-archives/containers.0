From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v4
Date: Fri, 14 Aug 2009 12:02:05 -0700
Message-ID: <1250276525.10725.6749.camel__7946.03544422916$1250276626$gmane$org@nimitz>
References: <20090723152647.D9391722@kernel>
	<20090724163814.08c7eee3.akpm@linux-foundation.org>
	<e9c3a7c20908141056o32ce1204k6751b43271aa88ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e9c3a7c20908141056o32ce1204k6751b43271aa88ab-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-08-14 at 10:56 -0700, Dan Williams wrote:
> On Fri, Jul 24, 2009 at 4:38 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > On Thu, 23 Jul 2009 08:26:47 -0700
> > Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >
> >>  linux-2.6.git-dave/include/linux/flex_array.h |   46 ++++
> >>  linux-2.6.git-dave/lib/Makefile               |    2
> >>  linux-2.6.git-dave/lib/flex_array.c           |  269 ++++++++++++++++++++++++++
> >
> > I haven't looked at this lately but I merged it.
> >
> > As it's obviously non-injurious, we could slip it into 2.6.31 for
> > convenience's sake but without any callers that's just runtime bloat.
> > So I guess we wait for some additional callers to come along and prove
> > its worth.
> 
> I am considering using this for managing the descriptor ring in a
> device driver, but I am concerned with the overhead of the divides.
> Would it be acceptable to round the element size to the next
> power-of-2 value so we can replace all the divides with shifts?

I think we have two options.  We can programatically determine and store
the shift, like this (during allocation):

	if (can_shift)
		fa->element_size = -log2(element_size);
	else
		fa->element_size = element_size;

Then, when dividing, we look for the "negative" offset size and do:

	if (element_size < 0)
		index = foo >> fa->element_size;
	else
		index = foo / fa->element_size;

Or, we can do what I'm doing in this patch.  If you want to specify the
index sizes to flex_array_put/get(), there's a flex_array_put_es()
(element size) variant.  It should inline enough to let the compiler
take care of this for us and turn the divides into shifts.

I just hacked this up *REALLY* quickly.  Not even compile tested.  I'll
look at it in some more detail early next week.  I'm not even positive
this will work.  Just releasing early and often. :)

diff --git a/include/linux/flex_array.h b/include/linux/flex_array.h
index 23c1ec7..9052704 100644
--- a/include/linux/flex_array.h
+++ b/include/linux/flex_array.h
@@ -36,6 +36,47 @@ struct flex_array {
 	.total_nr_elements = (total),	\
 } } }
 
+static inline int __elements_per_part(int element_size)
+{
+	return FLEX_ARRAY_PART_SIZE / element_size;
+}
+
+static int __fa_element_to_part_nr(struct flex_array *fa, int element_size
+		int element_nr)
+{
+	return element_nr / __elements_per_part(element_size);
+}
+
+static int __fa_index_inside_part(struct flex_array *fa, int element_size,
+		int element_nr)
+{
+	return element_nr % __elements_per_part(element_size);
+}
+
+void *flex_array_get_es(struct flex_array *fa, int element_nr, int element_size);
+{
+	int part_nr = __fa_element_to_part_nr(fa, element_nr, element_size);
+	int index_inside_part = index_inside_part(fa, element_nr);
+
+	if (element_nr >= fa->total_nr_elements)
+		return -ENOSPC;
+
+	return flex_array_get_precalc(fa, part_nr, index_inside_part);
+}
+
+int flex_array_put_es(struct flex_array *fa, int element_nr, int element_size,
+		      void *src, gfp_t flags);
+{
+	int part_nr = __fa_element_to_part_nr(fa, element_nr, element_size);
+	int index_inside = index_inside_part(fa, element_nr);
+
+	if (element_nr >= fa->total_nr_elements)
+		return NULL;
+
+	return flex_array_put_precalc(fa, part_nr, index_inside, src, flags);
+}
+
+
 struct flex_array *flex_array_alloc(int element_size, int total, gfp_t flags);
 int flex_array_prealloc(struct flex_array *fa, int start, int end, gfp_t flags);
 void flex_array_free(struct flex_array *fa);
diff --git a/lib/flex_array.c b/lib/flex_array.c
index 08f1636..0b2030d 100644
--- a/lib/flex_array.c
+++ b/lib/flex_array.c
@@ -115,11 +115,6 @@ struct flex_array *flex_array_alloc(int element_size, int total, gfp_t flags)
 	return ret;
 }
 
-static int fa_element_to_part_nr(struct flex_array *fa, int element_nr)
-{
-	return element_nr / __elements_per_part(fa->element_size);
-}
-
 /**
  * flex_array_free_parts - just free the second-level pages
  * @src:	address of data to copy into the array
@@ -153,7 +148,7 @@ static int fa_index_inside_part(struct flex_array *fa, int element_nr)
 
 static int index_inside_part(struct flex_array *fa, int element_nr)
 {
-	int part_offset = fa_index_inside_part(fa, element_nr);
+	int part_offset = fa_index_inside_part(fa, fa->element_size, element_nr);
 	return part_offset * fa->element_size;
 }
 
@@ -176,6 +171,17 @@ __fa_get_part(struct flex_array *fa, int part_nr, gfp_t flags)
 	return part;
 }
 
+
+static int fa_element_to_part_nr(struct flex_array *fa, int element_nr)
+{
+	return __fa_element_to_part_nr(fa, fa->element_size, element_nr);
+}
+
+static int fa_index_inside_part(struct flex_array *fa, int element_nr)
+{
+	return __fa_index_inside_part(fa, fa->element_size, element_nr);
+}
+
 /**
  * flex_array_put - copy data into the array at @element_nr
  * @src:	address of data to copy into the array
@@ -188,9 +194,17 @@ __fa_get_part(struct flex_array *fa, int part_nr, gfp_t flags)
  *
  * Locking must be provided by the caller.
  */
-int flex_array_put(struct flex_array *fa, int element_nr, void *src, gfp_t flags)
+int flex_array_put(struct flex_array *fa, int element_nr, void *src,
+		   gfp_t flags)
 {
 	int part_nr = fa_element_to_part_nr(fa, element_nr);
+	int index_inside = index_inside_part(fa, element_nr);
+
+	return flex_array_put_precalc(fa, part_nr, index_inside, src, flags);
+}
+int flex_array_put_precalc(struct flex_array *fa, int part_nr,
+			   int index_inside_part, void *src, gfp_t flags)
+{
 	struct flex_array_part *part;
 	void *dst;
 
@@ -253,15 +267,23 @@ int flex_array_prealloc(struct flex_array *fa, int start, int end, gfp_t flags)
 void *flex_array_get(struct flex_array *fa, int element_nr)
 {
 	int part_nr = fa_element_to_part_nr(fa, element_nr);
-	struct flex_array_part *part;
+	int index_inside_part = index_inside_part(fa, element_nr);
 
 	if (element_nr >= fa->total_nr_elements)
 		return NULL;
+
+	return flex_array_get_precalc(fa, part_nr, index_inside_part);
+}
+void *flex_array_get_precalc(struct flex_array *fa, int part_nr,
+			     int index_inside_part)
+{
+	struct flex_array_part *part;
+
 	if (!fa->parts[part_nr])
 		return NULL;
 	if (elements_fit_in_base(fa))
 		part = (struct flex_array_part *)&fa->parts[0];
 	else
 		part = fa->parts[part_nr];
-	return &part->elements[index_inside_part(fa, element_nr)];
+	return &part->elements[index_inside_part];
 }


-- Dave
