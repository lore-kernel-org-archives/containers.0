From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Thu, 21 Aug 2008 11:43:30 -0400
Message-ID: <48AD8D22.7000604__32742.7104734399$1219337389$gmane$org@cs.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel> <200808112347.50245.arnd@arndb.de>
	<48AD0379.9030705@cs.columbia.edu>
	<200808211043.41387.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808211043.41387.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Arnd Bergmann wrote:
> On Thursday 21 August 2008, Oren Laadan wrote:
 >
>> Using a single handle (crid or a special file descriptor) to identify
>> the whole checkpoint is very useful - to be able to stream it (eg. over
>> the network, or through filters). It is also very important for future
>> features and optimizations. For example, to reduce downtime of the
>> application during checkpoint, one can use COW for dirty pages, and
>> only write-back the entire data after the application resumes execution.
>> Or imagine a use-case where one would like to keep the entire checkpoint
>> in memory. These are pretty hard to do if you split the handling between
>> multiple files or handles.
> 
> right.
> 
>>> On the restart side, I think the most consistent interface would
>>> be a new binfmt_chkpt implementation that you can use to execve
>>> a checkpoint, just like you execute an ELF file today. The binfmt
>>> can be a module (unlike a syscall), so an administrator that is
>>> afraid of the security implications can just disable it by not
>>> loading the module. In an execve model, the parent process can
>>> set up anything related to credentials as good as it's allowed
>>> to and then let the kernel do the rest.
>> This is an interesting idea but not without its problems. In particular,
>> a successful execve() by one thread destroys all the others.
> 
> Right, execve currently assumes that the new process starts up with
> a single thread, but a potential binfmt_chkpt would need to potentially
> start multithreaded. I guess this either requires execve to reuse
> the existing threads (assuming they have been set up correctly in
> advance) or to create new ones according to the context of the
> checkpoint data. It may not be as easy as I thought initially, but
> both seem possible.
> Restarting a whole set of processes from a checkpoint would be
> a relatively simple extension of that.
> 
>> Also, it isn't clear how this can work with pre-copying and live-migration;
>> And finally, I'm not sure how to handle shared objects in this manner.
> 
> What do you mean with pre-copying?
> How is live-migration different from restarting a previously saved
> task from the same machine?

By pre-copying I refer to the first stage of live-migration: to reduce
down time, much of the state of a container can be saved while tasks
are still running (most notably memory, but also file system snapshot,
if need be). Since the state may change, this is repeated - to save the
what changed in the meanwhile - until the delta is small enough. During
all this time the tasks continue to execute. At this point, we freeze
the container, save the last delta, and resume (in case of snapshot) or
or kill (in case of live-migration) the container. I'm not convinced that
execve() is the best way to handle this iterative process.

Also, with multiple tasks in a container, data for consecutive tasks
will appear in order in the checkpoint image. Moreover, a future
optimization would be the have multiple threads checkpoint the container,
with data interleaved in the checkpoint image stream. Here, too, I'm
not sure how execve()-like approach plays.

Finally there is the case of shared objects: v2 demonstrates this in
checkpoint/objhash.c (see also Documentation/checkpoint.txt). Again,
I'm not sure how execve() can adapt to this need.

I definitely agree that using something like execve() is elegant and
has its advantages. It just isn't clear to me that it is truly suitable
for the needs. Suggestions are welcome.

Oren.

> 
>> As for kernel module - it is easy to implement most of the checkpoint
>> restart functionality in a kernel module, leaving only the syscall stubs
>> in the kernel.
> 
> Yeah, I've done the same in spufs, but I still think it's ugly ;-)
> 
> 	Arnd <><
