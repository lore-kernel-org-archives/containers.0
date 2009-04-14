From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: checkpoint/restart: taking refcounts on kernel objects
Date: Tue, 14 Apr 2009 10:23:20 -0700
Message-ID: <1239729800.32604.92.camel__21472.132128156$1239729979$gmane$org@nimitz>
References: <20090410023539.GK27788@x200.localdomain>
	<20090413214701.GA24509@us.ibm.com>
	<20090414152752.GC27461@x200.localdomain>
	<20090414154139.GA8085@us.ibm.com>
	<20090414170419.GD27923@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090414170419.GD27923-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-04-14 at 21:04 +0400, Alexey Dobriyan wrote:
> > Right while I have opinions on some things in this list, I didn't
> > mean to imply positions on these items.  My question was:  are
> > there are differences you want to call out?
> 
> Sorry? "none needed" is relevant to only item 3. If tasks don't
> dissapear during checkpoint, why would netns dissapear.
> Taking refcount on checkpoint(2) is likely unneeded.
> 
> But it's low-level detail anyway.

I guess it is a matter of whether we consider a task that gets unfrozen
a kernel bug or not.  If we don't take refcounts and we do reference an
object that disappears, then we *certainly* have a kernel bug that can
crash the kernel.  If we take refcounts, we at least limit the ways in
which the kernel can crash when something screwy happens.

On the other hand, the objhash is a kinda weird way to do it.  Taking
and releasing arbitrary refcounts on arbitrary kernel objects one level
too much of abstraction for me.

Come to think of it...  In the pipe case, we're *guaranteed* to have
someone hold an extra refcount for us after we encounter the first side
of the pipe: the other side of the pipe.  If the other side isn't there,
then we didn't need to save the reference.  If it is there, it was
holding a refcount and we didn't need an extra one.

-- Dave
