From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Thu, 23 Jul 2009 07:30:01 -0700
Message-ID: <1248359401.24021.715.camel@nimitz>
References: <20090721220017.60A219D3@kernel>  <4A67CEB7.2080505@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A67CEB7.2080505-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-07-22 at 19:45 -0700, H. Peter Anvin wrote:
> > I call it a flexible array.  It does all of its work in
> > PAGE_SIZE bits, so never does an order>0 allocation.
> > The base level has PAGE_SIZE-2*sizeof(int) bytes of
> > storage for pointers to the second level.  So, with a
> > 32-bit arch, you get about 4MB (4183112 bytes) of total
> > storage when the objects pack nicely into a page.  It
> > is half that on 64-bit because the pointers are twice
> > the size.
> 
> I'm wondering if there is any use case which would require scaling below
> the PAGE_SIZE level... in which case it would be nice for it to
> gracefully decay to a single kmalloc allocation + some metadata.

For the pid_t case that actually spawned all this, I think it makes a
ton of sense.  It should be pretty easy to just cannibalize the
base->part[] pointers to use for data if (total*element_size <=
bytes_allocated - sizeof(metadata)) in the base.  We'd have to store the
requested allocation total, but that's not bad.

1. Do we use this mode *only* when using a small 'total'?  Or, do we
   use the mode only when accessing a small range of elements, like
   indexes < 511.
2. Do we just use the mode when the indexes are large, but not sparse?
   Say, when someone is only using indexes 1024->1535?
3. Do we ever allocate less than 1 page (i.e. kmalloc(2048)) for the
   base given a small enough 'total' requested?  If so, it gets much
   harder to grow the array later on if we want to support resizing.
4. Do we ever promote under the covers from this mode up to the full
   two-level one?

This also gives us more of a reason to store a flex_array->total and
enforce that the array is not allowed to grow past that.

-- Dave
