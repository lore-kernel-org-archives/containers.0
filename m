From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
	restart
Date: Tue, 16 Dec 2008 14:14:01 -0800
Message-ID: <1229465641.17206.350.camel__6389.23643059588$1229465849$gmane$org@nimitz>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	<1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
	<49482394.10006@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49482394.10006-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linux Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-12-16 at 13:54 -0800, Mike Waychison wrote:
> Oren Laadan wrote:
> > diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> > index 375129c..bd14ef9 100644
> > --- a/checkpoint/sys.c
> > +++ b/checkpoint/sys.c
> 
> > +/*
> > + * During checkpoint and restart the code writes outs/reads in data
> > + * to/from the checkpoint image from/to a temporary buffer (ctx->hbuf).
> > + * Because operations can be nested, use cr_hbuf_get() to reserve space
> > + * in the buffer, then cr_hbuf_put() when you no longer need that space.
> > + */
> 
> This seems a bit over-kill for buffer management no?  The only large 
> header seems to be cr_hdr_head and the blowup comes from utsinfo string 
> data (which could easily be moved out to be in it's own CR_HDR_STRING 
> blocks).
> 
> Wouldn't it be easier to use stack-local storage than balancing the 
> cr_hbuf_get/put routines?

I've asked the same question, so I'll give you Oren's response that I
remember:

cr_hbuf_get/put() are more of an API that we can use later.  For now,
those buffers really are temporary.  But, in a case where we want to do
a really fast checkpoint (to reduce "downtime" during the checkpoint) we
store the image entirely in kernel memory to be written out later.

In that case, cr_hbuf_put() stops doing anything at all because we keep
the memory around.

cr_hbuf_get() becomes, "I need some memory to write some checkpointy
things into".

cr_hbuf_put() becomes, "I'm done with this for now, only keep it if
someone else needs it."

This might all be a lot clearer if we just kept some more explicit
accounting around about who is using the objects.  Something like:

struct cr_buf {
	struct kref ref;
	int size;
	char buf[0];
};

/* replaces cr_hbuf_get() */
struct cr_buf *alloc_cr_buf(int size, gfp_t flags)
{
	struct cr_buf *buf;

	buf = kmalloc(sizeof(cr_buf) + size, flags);
	if (!buf)
		return NULL;
	buf->ref = 1; /* or whatever */
	buf->size = size;
	return buf;
}

int cr_kwrite(struct cr_buf *buf)
{
	if (writing_checkpoint_now) {
		// or whatever this write call was...
		vfs_write(&buf->buf[0], buf->size);
	} else if (deferring_write) {		
		kref_get(buf->kref);
	}
}

-- Dave
