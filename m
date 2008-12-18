From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
Date: Thu, 18 Dec 2008 07:05:20 -0800
Message-ID: <1229612720.17206.505.camel__17441.3589913913$1229612954$gmane$org@nimitz>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	<1228498282-11804-6-git-send-email-orenl@cs.columbia.edu>
	<4949B4ED.9060805@google.com>  <494A2F94.2090800@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <494A2F94.2090800-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linux Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-12-18 at 06:10 -0500, Oren Laadan wrote:
> >> +    mutex_lock(&mm->context.lock);
> >> +
> >> +    hh->ldt_entry_size = LDT_ENTRY_SIZE;
> >> +    hh->nldt = mm->context.size;
> >> +
> >> +    cr_debug("nldt %d\n", hh->nldt);
> >> +
> >> +    ret = cr_write_obj(ctx, &h, hh);
> >> +    cr_hbuf_put(ctx, sizeof(*hh));
> >> +    if (ret < 0)
> >> +        goto out;
> >> +
> >> +    ret = cr_kwrite(ctx, mm->context.ldt,
> >> +            mm->context.size * LDT_ENTRY_SIZE);
> > 
> > Do we really want to emit anything under lock?  I realize that this
> > patch goes and does a ton of writes with mmap_sem held for read -- is
> > this ok?
> 
> Because all tasks in the container must be frozen during the checkpoint,
> there is no performance penalty for keeping the locks. Although the object
> should not change in the interim anyways, the locks protects us from, e.g.
> the task unfreezing somehow, or being killed by the OOM killer, or any
> other change incurred from the "outside world" (even future code).
> 
> Put in other words - in the long run it is safer to assume that the
> underlying object may otherwise change.
> 
> (If we want to drop the lock here before cr_kwrite(), we need to copy the
> data to a temporary buffer first. If we also want to drop mmap_sem(), we
> need to be more careful with following the vma's.)
> 
> Do you see a reason to not keeping the locks ?

Mike, although we're doing writes of the checkpoint file here, the *mm*
access is read-only.  We only need really mmap_sem for write if we're
creating new VMAs, which we only do on restore.  Was there an action
taken on the mm that would require a write that we missed?

Oren, I never considered the locking overhead, either.  The fact that
the processes are frozen is very, very important here.  The code is fine
as it stands because this *is* a very simple way to do it.  But, this
probably deserves a comment. 

-- Dave
