From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation
Date: Tue, 21 Jul 2009 10:22:30 -0700
Message-ID: <1248196950.13249.5515.camel__7776.90395848385$1248197043$gmane$org@nimitz>
References: <20090721160333.96AA4D3D@kernel>  <4A65F13D.6060506@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A65F13D.6060506-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-07-21 at 12:47 -0400, Mike Waychison wrote:
> > +/*
> > + * This is meant to replace cases where an array-like
> > + * structure has gotten to big to fit into kmalloc()
> 
> s/to/too/g

Gah, thanks.

> > + * and the developer is getting tempted to use
> > + * vmalloc().
> > + */
> > +
> > +struct flex_array {
> > +	union {
> > +		struct {
> > +			int nr_elements;
> > +			int element_size;
> > +			struct flex_array_part *parts[0];
> > +		};
> > +		/*
> > +		 * This little trick makes sure that
> > +		 * sizeof(flex_array) == PAGE_SIZE
> > +		 */
> > +		char padding[FLEX_ARRAY_BASE_SIZE];
> > +	};
> > +};
> > +
> > +struct flex_array *alloc_flex_array(int element_size, int total, gfp_t flags);
> > +void free_flex_array(struct flex_array *fa);
> > +int flex_array_put(struct flex_array *fa, void *src, gfp_t flags);
> > +void *flex_array_get(struct flex_array *fa, int element_nr);
> 
> Would a single routine that acted like an lvalue be a bit clearer?  Here 
> it looks like the interface is a push to write, but random access to 
> read.  Something like:
> 
> void **__flex_array_idx(struct flex_rray *fa, int element_nr);
> #define flex_array_idx(fa, element_nr) (*__flex_array_idx(fa, element_nr))
> 
> may be a bit easier to read so users of the interface could just do:
> 
> flex_array_idx(fa, n) = pointer;
> pointer = flex_array_idx(fa, n);
> 
> I guess this would require that flex_array only store actual pointers 
> though, instead of objects.  Hmm.

Yeah, possibly.  

I was hoping I'd get some suggestions for places in the kernel that
could use this.  I'll see if another interface looks better once I get
some users. :)

> Is there any reason you defer allocation of parts to flex_array_put() 
> given that alloc_flex_array() is told the total number of elements?

Yeah, I guess it's just in the hope that it won't all get filled.  I
think I also started with it not being passed the total size.  But, I
figured later on that it was better to fail as early as possible rather
than screwing the user later on when we fill up. 

> > +struct flex_array_part {
> > +	char elements[FLEX_ARRAY_PART_SIZE];
> > +};
> > +
> > +static inline int __elements_per_part(int element_size)
> > +{
> > +	return FLEX_ARRAY_PART_SIZE / element_size;
> 
> Micro-optimization, but perhaps the general case could use a bit shift 
> stored inside the flex_array?  That way we could avoid excessive divide 
> operations.

Possibly, but that of course precludes having objects with
non-power-of-two sizes being packed very well.  It's certainly worth
thinking about.

> > +void *flex_array_get(struct flex_array *fa, int element_nr)
> > +{
> > +	int part_nr = fa_element_to_part_nr(fa, element_nr);
> > +	struct flex_array_part *part;
> > +	int offset;
> > +
> > +	if (part_nr > __nr_part_ptrs())
> 
> if (part_nr >= __nr_part_ptrs())

Yep.  Good catch.

> > +		return NULL;
> 
> ERR_PTR(-EINVAL) ?

I guess this helps users differentiate bad arguments from memory
allocation failures.  But, I'd rather not make users check ERR_PTR()
just because I want to keep it simple.  

> Would it make sense to WARN here?  A more precise test could be to 
> compare element_nr vs fa->nr_elements?

My immediate goal here was just to avoid oopses and overflows.  You're
right that fa->nr_elements would be more precise.  But, I guess if you
overflow an array you get an oops, so why should this be any different?
A WARN() is potentially noisy, but way less noisy than an oops.  

Thanks for the feedback!

-- Dave
