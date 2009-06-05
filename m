From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch
	/proc/*/exe
Date: Fri, 5 Jun 2009 20:09:43 +0400
Message-ID: <20090605160943.GA5262__12377.5192340419$1244218557$gmane$org@x200.localdomain>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
	<20090605104517.GA11713@infradead.org>
	<alpine.LFD.2.01.0906050808551.6847@localhost.localdomain>
	<20090605154147.GA16766@x200.localdomain>
	<alpine.LFD.2.01.0906050848520.6847@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0906050848520.6847-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jun 05, 2009 at 08:49:56AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 5 Jun 2009, Alexey Dobriyan wrote:
> > 
> > This mapping issue is what created VM_EXECUTABLE/MAP_EXECUTABLE in
> > the first place, I assume? Never mind it's cheap hack.
> > 
> > > and goes along with task->mm, and should be there, not in task_struct.
> > 
> > Because ->mm can be borrowed to unrelated task and user has to check
> > for it.
> 
> Not it can't.
> 
> You're confusing ->mm with ->active_mm.
> 
> The latter can be borrowed. The former can not.

Not permanently, but it can:

	static void aio_kick_handler(struct work_struct *work)
	{
	        struct kioctx *ctx = container_of(work, struct kioctx, wq.work);
	        mm_segment_t oldfs = get_fs();
	        struct mm_struct *mm;
	        int requeue;
	
	        set_fs(USER_DS);
	        use_mm(ctx->mm);
	        spin_lock_irq(&ctx->ctx_lock);
	        requeue =__aio_run_iocbs(ctx);
	        mm = ctx->mm;
	        spin_unlock_irq(&ctx->ctx_lock);
	        unuse_mm(mm);
	        set_fs(oldfs);
	        /*
	         * we're in a worker thread already, don't use
	         * queue_delayed_work,
	         */
	        if (requeue)
	                queue_delayed_work(aio_wq, &ctx->wq, 0);
	}

It's borrowed by kernel thread of course, not userspace task.

> The fact is, the executable is _inherently_ tied to the mm. It's what it 
> is mapped into. It makes no sense to tie it to anything else. It's simply 
> fundamentally not a "per-thread" thing.
