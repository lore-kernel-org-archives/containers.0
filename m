From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Tue, 21 Jul 2009 15:35:24 -0700
Message-ID: <20090721153524.54a08fa5.akpm__43672.678320627$1248215835$gmane$org@linux-foundation.org>
References: <20090721220017.60A219D3@kernel>
	<1248214145.13249.5671.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248214145.13249.5671.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 21 Jul 2009 15:09:05 -0700
Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> On Tue, 2009-07-21 at 15:00 -0700, Dave Hansen wrote:
> > 
> > The interface is dirt simple.  4 functions:
> >         alloc_flex_array()
> >         free_flex_array()
> >         flex_array_put()
> >         flex_array_get()
> > 
> > put() appends an item into the array while get() takes
> > indexes and does array-style access.
> 
> I need to update this description, but the kerneldoc comments are up to
> date.
> 
> That reminds me...  People will get somewhat weird behavior if they mix
> flex_array_append() and flex_array_put().  Is that OK?  Should
> flex_array_put() modify ->nr_elements to point to the element past the
> one that was just put()?  Should we perhaps drop the append() function
> and the ->nr_elements variable completely?

I'd say that we can drop ->append.  C arrays don't have an `append', and
callers trivially append stuff to arrays all the time.  `for (i = 0; i < ....'
