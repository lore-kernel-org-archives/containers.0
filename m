From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation
Date: Tue, 21 Jul 2009 10:25:30 -0700
Message-ID: <1248197130.13249.5520.camel@nimitz>
References: <20090721160333.96AA4D3D@kernel>
	<1158166a0907210957p6fb73ed7pc7f5bb9f9ad6eac2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1158166a0907210957p6fb73ed7pc7f5bb9f9ad6eac2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Denys Vlasenko <vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-07-21 at 18:57 +0200, Denys Vlasenko wrote:
> On Tue, Jul 21, 2009 at 6:03 PM, Dave Hansen<dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> > +static inline struct flex_array_part *
> > +__fa_get_part(struct flex_array *fa, int part_nr, gfp_t flags)
> > +{
> > +       struct flex_array_part *part = NULL;
> > +       if (part_nr > __nr_part_ptrs())
> > +               return NULL;
> > +       part = fa->parts[part_nr];
> > +       if (!part) {
> > +               part = kmalloc(FLEX_ARRAY_PART_SIZE, flags);
> > +               if (!part)
> > +                       return NULL;
> > +               fa->parts[part_nr] = part;
> > +       }
> > +       return part;
> > +}
> 
> This is far too big to be an inline.

Yeah, I guess I should just leave it to the compiler to inline it since
it's only used in one place.

-- Dave
