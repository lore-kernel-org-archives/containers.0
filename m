From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: checkpoint/restart: taking refcounts on kernel objects
Date: Fri, 1 May 2009 16:56:05 +0400
Message-ID: <20090501125605.GA10942__16197.3033486449$1241182608$gmane$org@x200.localdomain>
References: <20090410023539.GK27788@x200.localdomain>
	<20090413214701.GA24509@us.ibm.com>
	<20090414152752.GC27461@x200.localdomain>
	<20090414154139.GA8085@us.ibm.com>
	<20090414170419.GD27923@x200.localdomain>
	<1239729800.32604.92.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239729800.32604.92.camel@nimitz>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 14, 2009 at 10:23:20AM -0700, Dave Hansen wrote:
> On Tue, 2009-04-14 at 21:04 +0400, Alexey Dobriyan wrote:
> > > Right while I have opinions on some things in this list, I didn't
> > > mean to imply positions on these items.  My question was:  are
> > > there are differences you want to call out?
> > 
> > Sorry? "none needed" is relevant to only item 3. If tasks don't
> > dissapear during checkpoint, why would netns dissapear.
> > Taking refcount on checkpoint(2) is likely unneeded.
> > 
> > But it's low-level detail anyway.
> 
> I guess it is a matter of whether we consider a task that gets unfrozen
> a kernel bug or not.  If we don't take refcounts and we do reference an
> object that disappears, then we *certainly* have a kernel bug that can
> crash the kernel.  If we take refcounts, we at least limit the ways in
> which the kernel can crash when something screwy happens.
> 
> On the other hand, the objhash is a kinda weird way to do it.  Taking
> and releasing arbitrary refcounts on arbitrary kernel objects one level
> too much of abstraction for me.

Hm, I take this objection back (refcounts at checkpoint(2) time).
It's easier and safer to always grab it when putting checkpointed object
to hash/list/whatever to maintain refcount correct.
On context destroy, every object is put regardless of whether it's
checkpointing or restarting.
