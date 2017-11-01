From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 3/5] userns: Don't read extents twice in m_start
Date: Wed, 1 Nov 2017 17:29:33 +0100
Message-ID: <20171101162932.hfetkatdwcdqmqfi@gmail.com>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
	<871sliubhj.fsf_-_@xmission.com> <87k1zaswu6.fsf_-_@xmission.com>
	<143adb61-fb8e-fc1b-396b-b18836e68766@suse.com>
	<87a806ntn0.fsf@xmission.com>
	<20171101130539.j5bxmhs2trqurrr2@hirez.programming.kicks-ass.net>
	<20171101140144.zwe7cq7iv2xudwp4@gmail.com>
	<20171101141654.fr4rs2m5cygouktb@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171101141654.fr4rs2m5cygouktb-Nxj+rRp3nVydTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: tycho-E0fblnxP3wo@public.gmane.org, Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 01, 2017 at 03:16:54PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 01, 2017 at 03:01:45PM +0100, Christian Brauner wrote:
> > Tbf, this isn't solely Eric's fault. I'm to blame here too since I didn't
> > document the already existing smb_rmb()s and the new one I introduced when
> > writing the patches. I didn't know that there was a hard-set requirement to
> > document those. I also didn't see anything in the kernel coding style or the
> > memory barriers documentation (But it has been some time since I read those.).
> 
> There's too many documents to read.. I'm not sure we changed
> coding-style, and I suspect that'll just end up being another bike-shed
> in any case.
> 
> We did get checkpatch changed though, which is a strong enough clue that
> something needs to happen.
> 
> But What Nikolay said; memory ordering is hard enough if you're clear on
> what exactly you intend to do. But if you later try and reconstruct
> without comments, its nearly impossible.

Yeah, agreed. I was happy to see that Eric explained his smp_wmb() in detail.
That was quite helpful in figuring this out!

> 
> It gets even better if someone changes the ordering requirements over
> time and you grow hidden and non-obvious dependencies :/
> 
> > > Also, you probably want READ_ONCE() here and WRITE_ONCE() in
> > > map_write(), the compiler is free to do unordered byte loads/stores
> > > without it.
> > > 
> > > And finally, did you want to use smp_store_release() and
> > > smp_load_acquire() instead?
> > 
> > Maybe a stupid question but do you suspect this is a real problem in
> > this case since you're phrasing it as a question?
> 
> Rhetorical question mostly, I suspect its just what you meant to do, as
> per the proposed patch.
> 
> > Iirc, *_acquire() operations include
> > locking operations and might come with a greater performance impact then
> > smb_{rmb,wmb}(). Given that this is a very performance critical path we should
> > be sure.
> 
> No locking what so ever. LOAD-ACQUIRE and STORE-RELEASE are memory ordering
> flavours that are paired with the respective memory operation.

Ah right, now I remember I was confused by a part of the memory barriers
documentation that referenced locks. Acquire operations include locks and
smp_load_acquire().  Right, should've remembered that. Thanks!

> 
> It is true that locking ops provide these exact orderings, but that
> doesn't imply the reverse.
> 
> In short, store-release is a store that ensures all prior load _and_
> stores happen-before this store. A load-acquire is a load which
> happens-before any subsequent load or stores.
> 
> But a release does not constrain later loads or stores, and an acquire
> does not constrain prior load or stores.
> 
> 
