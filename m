From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Thu, 05 Mar 2009 13:27:07 -0800
Message-ID: <1236288427.22399.122.camel__43579.4121622623$1236288556$gmane$org@nimitz>
References: <20090305163857.0C18F3FD@kernel>
	<20090305174037.GA2274@x200.localdomain>
	<1236280567.22399.99.camel@nimitz>
	<20090305210840.GA2499@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305210840.GA2499-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-03-06 at 00:08 +0300, Alexey Dobriyan wrote:
> On Thu, Mar 05, 2009 at 11:16:07AM -0800, Dave Hansen wrote:
> > On Thu, 2009-03-05 at 20:40 +0300, Alexey Dobriyan wrote:
> > > * without recalculating "checkpointable" property on fs_struct
> > >   on every C/R=y kernel.
> > 
> > Yeah, this is certainly less than ideal.  Although, I haven't seen your
> > proposal for where to tie your code into the kernel.  Do you suggest
> > that we do nothing during normal kernel runtime and all the checking at
> > sys_checkpoint() time?
> 
> Of course!
> 
> C/R won't be used by majority of users, so it shouldn't bring any
> overhead. ->f_op->checkpoint (not ->checkpointable!) is probably
> acceptable. Recalculating flags is not, sorry.

Yeah, what I'm doing in dup_fd() is certainly suboptimal.  It introduces
extra overhead in fork() (with the config option turned on) which sucks
big time.  But, I'm *sure* we can optimize it, especially if we can push
it out to only occurring at "container fork()" time.  Whatever container
fork ends up being.  

> Imagine, unsupported file is opened between userspace checks
> for /proc/*/checkpointable and /proc/*/fdinfo/*/checkpointable
> and whatever, you stil have to do all the checks inside checkpoint(2).

Alexey, we have two problems here.  I completely agree that we have to
do complete and thorough checks of each file descriptor at
sys_checkpoint().  Any checks made at other times should not be trusted.

The other side is what Ingo has been asking for.  How do we *know* when
we are checkpointable *before* we call (and without calling)
sys_checkpoint()?  You are yet to acknowledge that this is a valid use
case, but it is exactly what Ingo is asking for, I believe.

If nice printk()s are sufficient to cover what Ingo wants, I'm quite
happy to remove the /proc files.  

> > > It may lack some printk, but printks are trivial to insert including
> > > using d_path for precise info.
> > 
> > This is definitely workable approach.  However, could you show how you
> > would support /dev/null and, say, /proc/$$/stat?  I've shown what it
> > takes to do that in my patches, and I think it would show a lot about
> > your approach.  
> 
> I haven't yet written code for /dev/null, but it would be:
> * at checkpoint(2)
> 	** see it's block device
> 	** see it's 1:3 => supported
> 	** dump "1:3", dump "/dev/null" as filename

Can we see code, please?  With my approach, it is a single line added to
a structure definition.  Your approach sounds like it may be more than a
single line of code.  It sounds like you would like to have some kind of
device number to c/r mapping.  I'm curious what form that would take.

> * at restore(2)
> 	** read CR_OBJ_FILE
> 	** open filename or -E
> 	** if not block device return -E
> 	** if not 1:3 return -E
> 	** save "struct file *" where needed
> 
> (all of this is modulo unlinked case)

/dev/null is a character device, btw. :)

This sanity checking on the sys_restore() side is also definitely a good
idea.  But, in the interests of keeping our patch size down, I think it
is safe to say that we require userspace to get the fs back into a state
consistent with sys_checkpoint() time.  

-- Dave
