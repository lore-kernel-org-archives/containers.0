From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v10][PATCH 05/13] Dump memory address space
Date: Mon, 01 Dec 2008 10:00:12 -0800
Message-ID: <1228154412.2971.44.camel__20444.1374670298$1228154691$gmane$org@nimitz>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	<1227747884-14150-6-git-send-email-orenl@cs.columbia.edu>
	<20081128105351.GQ28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081128105351.GQ28946-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-11-28 at 10:53 +0000, Al Viro wrote:
> 
> > +static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
> > +{
> > +     ctx->root_pid = pid;
> > +
> > +     /*
> > +      * assume checkpointer is in container's root vfs
> > +      * FIXME: this works for now, but will change with real containers
> > +      */
> > +     ctx->vfsroot = &current->fs->root;
> > +     path_get(ctx->vfsroot);
> 
> This is going to break as soon as you get another thread doing e.g. chroot(2)
> while you are in there.

Yeah, we do need at least a read_lock(&current->fs->lock) to keep people
from chroot()'ing underneath us.

> And it's a really, _really_ bad idea to take a
> pointer to shared object, increment refcount on the current *contents* of
> said object and assume that dropping refcount on the later contents of the
> same will balance out.

Absolutely.  I assume you mean get_fs_struct(current) instead of
path_get().

-- Dave
