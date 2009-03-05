From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Thu, 05 Mar 2009 11:16:07 -0800
Message-ID: <1236280567.22399.99.camel@nimitz>
References: <20090305163857.0C18F3FD@kernel>
	<20090305174037.GA2274@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305174037.GA2274-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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

On Thu, 2009-03-05 at 20:40 +0300, Alexey Dobriyan wrote:
> On Thu, Mar 05, 2009 at 08:38:57AM -0800, Dave Hansen wrote:
> > This takes a suggestion of Ingo's along with comments from lots of
> > other people.  It can track whether a given file is able to be
> > checkpointed.  It introduces a f_op to allow easy customization
> > like the reset of the VFS.
> 
> Here is how alternative looks like
> * without touching VFS at all
> * without adding default handlers

Are these bad things?  If this was harmful to the VFS, I can bet
Christoph would be speaking up.  As far as the default handlers, blame
Christoph. :)

> * without duplicate code every ->checkpoint hook will have

Well, I had actually planned to break the generic function up into a
"common" function that all of the handlers can call or could be called
before each handler.  This is trivially fixable, but it would look kinda
goofy without some code to use it.

> * without largely useless "special file" messages
>   (what's so special about it?)

Very true.  I'll improve that one.

> * without adding userspace-visible /proc/*/checkpointable 

Ingo, could you weigh in on how you expected this "checkpointable" flag
to get exposed to and checked by userspace?

> * without recalculating "checkpointable" property on fs_struct
>   on every C/R=y kernel.

Yeah, this is certainly less than ideal.  Although, I haven't seen your
proposal for where to tie your code into the kernel.  Do you suggest
that we do nothing during normal kernel runtime and all the checking at
sys_checkpoint() time?

> * with "ban by default" policy as well
> * with error message immediatly understandable by developer:
> 
> 	cr_check_file: can't checkpoint file f61a0f40, ->f_op = socket_file_ops+0x0/0x1c0

That's a much better error message than I have.  I think I'll steal it
if you don't mind.  

> It may lack some printk, but printks are trivial to insert including
> using d_path for precise info.

This is definitely workable approach.  However, could you show how you
would support /dev/null and, say, /proc/$$/stat?  I've shown what it
takes to do that in my patches, and I think it would show a lot about
your approach.  

-- Dave
