From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Thu, 21 Aug 2008 01:56:09 -0400
Message-ID: <48AD0379.9030705@cs.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel>
	<200808111853.13854.arnd@arndb.de>	<1218484114.5598.43.camel@nimitz>
	<200808112347.50245.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808112347.50245.arnd-r2nGTMty4D4@public.gmane.org>
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
> On Monday 11 August 2008, Dave Hansen wrote:
>> Thanks for all of the very interesting comments about the ABI.  
>>
>> Considering that we're still *really* early in getting this concept
>> merged up into mainline, what do you all think we should do now?
> 
> I think the two most important aspects here need to be security and
> simplicity. If you have to choose between the two, it probably makes
> sense to put security first, because loading untrusted data into
> the kernel puts you at a significant risk to start with. If you
> can show a restart interface that lets regular users restart their
> tasks in a way anyone can verify to be secure, that will be a
> good indication that you're on the right track.
> 
> The other problem that you really need to solve is interface
> stability. What you are creating is a binary representation
> of many kernel internal data structures, so in our common
> rules, you have to make sure that you remain forward and
> backward compatible. Simply saying that you need to run
> an identical kernel when restarting from a checkpoint is not
> enough IMHO.
> 

quoting:

 > There could be a case for viewing sys_restore() as being a lot like
 > sys_init_module() - a view into kernel internals that goes beyond the
 > normal user-space ABI, and beyond the stability guarantee.  It might be
 > possible to create a certain amount of version portability with a
 > modversions-like mechanism, but it sure seems hard to do better than
 > that.
 >
 > jon

Extending this view in the context of security - we can require sysadmin
privilege to restart, and then sysadmin is responsible for the contents
of the file. The kernel will ensure the the data isn't corrupted. Much
like with loading a kenrel module - the admin may load any sort of crap.
Then, sysadmin may, for instance, add a signature on a checkpointed file
to verify it's integrity.

(Well, one problem with this scheme in the context of self-checkpoint
would be - who can be trusted to generate the signature in that case).

> Some more words on specific interfaces that we have discussed:
> 
> The single-file-descriptor approach has the big advantage of
> keeping the complexity in one place (the kernel). To be consistent
> with other kernel interfaces, I would make the kernel hand out a
> file descriptor, not let the user open a file and pass that into
> the kernel as you do now.
> 
> A new file system is a good idea for many complex interfaces that
> make their way into the kernel, but I don't think it will help
> in this case.
> 
> For checkpointing a single task, or even a task with its children,
> a different interface I could imagine would be to have a new
> file in procfs per pid that you can read as a pipe giving our
> the same data that you currently save in the checkpoint file
> descriptor. It does mean that you won't be able to pass flags
> down easily (you could write to the pipe before you start reading,
> but that's not too nice).

Using a single handle (crid or a special file descriptor) to identify
the whole checkpoint is very useful - to be able to stream it (eg. over
the network, or through filters). It is also very important for future
features and optimizations. For example, to reduce downtime of the
application during checkpoint, one can use COW for dirty pages, and
only write-back the entire data after the application resumes execution.
Or imagine a use-case where one would like to keep the entire checkpoint
in memory. These are pretty hard to do if you split the handling between
multiple files or handles.

> 
> On the restart side, I think the most consistent interface would
> be a new binfmt_chkpt implementation that you can use to execve
> a checkpoint, just like you execute an ELF file today. The binfmt
> can be a module (unlike a syscall), so an administrator that is
> afraid of the security implications can just disable it by not
> loading the module. In an execve model, the parent process can
> set up anything related to credentials as good as it's allowed
> to and then let the kernel do the rest.

This is an interesting idea but not without its problems. In particular,
a successful execve() by one thread destroys all the others. Also, it
isn't clear how this can work with pre-copying and live-migration; And
finally, I'm not sure how to handle shared objects in this manner.

As for kernel module - it is easy to implement most of the checkpoint
restart functionality in a kernel module, leaving only the syscall stubs
in the kernel.

Oren.
