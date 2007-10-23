From: Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] CFS CGroup: Report usage
Date: Tue, 23 Oct 2007 22:11:24 +0530
Message-ID: <20071023164124.GA4666__38170.5932938077$1193157060$gmane$org@linux.vnet.ibm.com>
References: <471D4523.4040509@google.com>
	<20071023024036.GC3324@linux.vnet.ibm.com>
	<6599ad830710222306m6a3e3f52k4daf501836c05274@mail.gmail.com>
Reply-To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830710222306m6a3e3f52k4daf501836c05274-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Oct 22, 2007 at 11:06:54PM -0700, Paul Menage wrote:
> > > +     for_each_possible_cpu(i) {
> > > +             unsigned long flags;
> > > +             spin_lock_irqsave(&tg->cfs_rq[i]->rq->lock, flags);
> >
> > Is the lock absolutely required here?
> 
> I'm not sure, I was hoping you or Ingo could comment on this. But some
> kind of locking seems to required at least on 32-bit platforms, since
> sum_exec_runtime is a 64-bit number.

I tend to agree abt 32-bit platforms requiring a lock to read the 64-bit
sum_exec_runtime field.

Ingo/Dmitry, what do you think? fs/proc/array.c:task_utime() is also
buggy in that case.

-- 
Regards,
vatsa
