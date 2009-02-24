From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v13][PATCH 05/14] x86 support for checkpoint/restart
Date: Tue, 24 Feb 2009 08:06:46 -0800
Message-ID: <1235491606.26788.248.camel__3920.39436051181$1235491896$gmane$org@nimitz>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1233076092-8660-6-git-send-email-orenl@cs.columbia.edu>
	<20090224014739.1b82fc35@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224014739.1b82fc35-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-02-24 at 01:47 -0600, Nathan Lynch wrote:
> But I think this has been pointed out before.  If I understand the
> justification for cr_hbuf_get correctly, the allocations it services
> are somehow known to be bounded in size and nesting.  But even if that
> is the case, it's not much of a reason to avoid using kmalloc, is it?

Oren wants this particular facility to be used for live migration.  To
support good live migration, we need to be able to return from the
syscall as fast as possible.  To do that, Oren proposed that we buffer
all the data needed for the checkpoint inside the kernel.

The current cr_hbuf_put/get() could easily be modified to support this
usage by basically making put() do nothing, then handing off a handle to
the cr_ctx structure elsewhere in the kernel.  When the time comes to
free up the in-memory image, you only have one simple structure to go
free (the hbuf) as opposed to a bunch of little kmalloc()'d objects.

I'm sure I'm missing something.  I'm also sure that this *will* work
eventually.  But, I don't think the code as it stands supports keeping
the abstraction in there.  It is virtually impossible to debate the
design or its alternatives in this state.

-- Dave
