From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Thu, 21 Aug 2008 10:43:40 +0200
Message-ID: <200808211043.41387.arnd__7192.38177775896$1219308408$gmane$org@arndb.de>
References: <20080807224033.FFB3A2C1@kernel> <200808112347.50245.arnd@arndb.de>
	<48AD0379.9030705@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48AD0379.9030705-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 21 August 2008, Oren Laadan wrote:
> 
> Arnd Bergmann wrote:

> Extending this view in the context of security - we can require sysadmin
> privilege to restart, and then sysadmin is responsible for the contents
> of the file. The kernel will ensure the the data isn't corrupted. Much
> like with loading a kenrel module - the admin may load any sort of crap.
> Then, sysadmin may, for instance, add a signature on a checkpointed file
> to verify it's integrity.
> 
> (Well, one problem with this scheme in the context of self-checkpoint
> would be - who can be trusted to generate the signature in that case).

Sorry, I don't buy that argument. I'm convinced that an implementation
is possible where any user can load checkpoints of tasks that he could
create by starting the processes directly. If you argue that loading
a corrupted checkpoint can cause any problems, then I would assume
the restart code needs better permission and sanity checks.

> Using a single handle (crid or a special file descriptor) to identify
> the whole checkpoint is very useful - to be able to stream it (eg. over
> the network, or through filters). It is also very important for future
> features and optimizations. For example, to reduce downtime of the
> application during checkpoint, one can use COW for dirty pages, and
> only write-back the entire data after the application resumes execution.
> Or imagine a use-case where one would like to keep the entire checkpoint
> in memory. These are pretty hard to do if you split the handling between
> multiple files or handles.

right.

> > On the restart side, I think the most consistent interface would
> > be a new binfmt_chkpt implementation that you can use to execve
> > a checkpoint, just like you execute an ELF file today. The binfmt
> > can be a module (unlike a syscall), so an administrator that is
> > afraid of the security implications can just disable it by not
> > loading the module. In an execve model, the parent process can
> > set up anything related to credentials as good as it's allowed
> > to and then let the kernel do the rest.
> 
> This is an interesting idea but not without its problems. In particular,
> a successful execve() by one thread destroys all the others.

Right, execve currently assumes that the new process starts up with
a single thread, but a potential binfmt_chkpt would need to potentially
start multithreaded. I guess this either requires execve to reuse
the existing threads (assuming they have been set up correctly in
advance) or to create new ones according to the context of the
checkpoint data. It may not be as easy as I thought initially, but
both seem possible.
Restarting a whole set of processes from a checkpoint would be
a relatively simple extension of that.

> Also, it isn't clear how this can work with pre-copying and live-migration;
> And finally, I'm not sure how to handle shared objects in this manner.

What do you mean with pre-copying?
How is live-migration different from restarting a previously saved
task from the same machine?


> As for kernel module - it is easy to implement most of the checkpoint
> restart functionality in a kernel module, leaving only the syscall stubs
> in the kernel.

Yeah, I've done the same in spufs, but I still think it's ugly ;-)

	Arnd <><
