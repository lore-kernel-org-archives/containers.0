From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Tue, 14 Apr 2009 20:00:03 +0400
Message-ID: <20090414160003.GD27461__11572.1005517573$1239726639$gmane$org@x200.localdomain>
References: <20090410023539.GK27788@x200.localdomain>
	<49E41D7B.8030003@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E41D7B.8030003-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 14, 2009 at 01:22:03AM -0400, Oren Laadan wrote:
> 
> Alexey Dobriyan wrote:
> > * add struct file_operations::checkpoint
> > 
> >   The point of hook is to serialize enough information to allow restoration
> >   of an opened file.
> > 
> >   The idea (good one!) is that the code which supplies struct file_operations
> >   know better what to do with file.
> 
> Actually, credit is due to Dave Hansen (or Christoph Hellwig, or both?).
> 
> > 
> >   Hook gets C/R context (a cookie more or less) on which dump code can
> >   cr_write() and small restrictions on what to write: globally unique object id
> >   and correct object length to allow jumping through objects.
> > 
> >   For usual files on on-disk filesystem add generic_file_checkpoint()
> > 
> >   Add ext3 opened regular files and directories for start.
> > 
> >   No ->checkpoint, checkpointing is aborted -- deny by default.
> > 
> > FIXME: unlinked, but opened files aren't supported yet.
> > 
> > * C/R image design
> > 
> >   The thing should be flexible -- kernel internals changes every day, so we can't
> >   really afford a format with much enforced structure.
> > 
> >   Image consists of header, object images and terminator.
> > 
> >   Image header consists of immutable part and mutable part (for future).
> > 
> >   Immutable header part is magic and image version: "LinuxC/R" + __le32
> > 
> >   Image version determines everything including image header's mutable part.
> >   Image version is going to be bumped at earliest opportunity following changes
> >   in kernel internals.
> > 
> >   So far image header mutable part consists of arch of the kernel which dumped
> >   the image (i386, x86_64, ...) and kernel version as found in utsname.
> > 
> >   Kernel version as string is for distributions. Distro can support C/R for
> >   their own kernels, but can't realistically be expected to bump image version --
> >   this will conflict with mainline kernels having used same version. We also don't
> >   want requests for private parts of image version space.
> 
> So far so good, like in our patch-set.
> 
> You also need to address differences in configuration (kernel could
> have been recompiled) and runtime environment (boot params, etc).
> 
> We deferred this issue to a later time.
> 
> > 
> >   Distro expected to keep image version alone and on restart(2) check utsname
> >   version and compare it against previously release kernel versions and based
> >   on that turn on compatibility code.
> 
> Are you suggesting that conversion of a checkpoint image from an older
> version to a newer version be done in the kernel ?

For mainline kernel it's completely unrealistic to support all backwards
compatibility code for previous versions. Some mythical userspace
program will convert images.

But it's completely realistic and much easier for distro kernel because
distro kernel doesn't generally include patches with significant in-kernel
internals changes, so they simply can support
'2.6.26-1-amd64' => '2.6.26-2-amd64' situation.

Distros can write conversion program too, but I don't expect they will.

> It may work for a few versions, and then you'll get a spaghetti of
> #ifdef's in the code, together with a plethora of legacy code.

Expectation is for one kernel branch like RHEL5 kernel updates during
RHEL5 lifecycle.

For RHEL5 => RHEL6, it's up to them what to do.

Anyway distro can add compat code _anyway_, for this we help them with
this image format tweak, so they won't bug mainline with "reserve bit 31
for Red Hat".

Image version is kept small (__le32) for this reason too :-)

> It is much better/easier to handle checkpoint image transformations
> in user space. The kernel will only understand its "current" version
> (for some definition of version).
> 
> > 
> >   Object image is very flexible, the only required parts are a) object type (u32)
> >   and b) object total length (u32, [knocks wood]) which must be at the beginning
> >   of an image. The rest is not generic C/R code problem.
> > 
> >   Object images follow one another without holes. Holes are in theory possible but
> >   unneeded.
> > 
> 
> When would you need holes ?
> 
> >   Image ends with terminator object. This is mostly to be sure, that, yes, image
> >   wasn't truncated for some reason.
> > 
> > 
> > * Objects subject to C/R
> > 
> >   The idea is to not be very smart but directly dump core kernel data structures
> >   related to processes. This includes in this patch:
> > 
> > 	struct task_struct
> > 	struct mm_struct
> > 	VMAs
> > 	dirty pages
> > 	struct file
> > 
> >   Relations between objects (task_struct has pointer to mm_struct) are fullfilled
> >   by dumping pointed to object first, keeping it's position in dumpfile and saving
> >   position in a image of pointe? object:
> 
> Unless you use the physical position to actually lseek to there to
> re-read the data, there is no reason to use the actual position. In
> fact it is easier to debug when the shared object identifier is a
> simple counter.
> 
> If you do use it to lseek, then it's a poor decision -- sounds fragile:
> what if we change the file (legitimately) adding data in the middle -
> the whole concept breaks.

Adder of data is expected to understand image format and update all references
just like surgeon is expected to understand human anatomy.

> > 	struct cr_image_task_struct {
> > 		cr_pos_t	cr_pos_mm;
> > 			...
> > 	};
> > 
> >   Code so far tries hard to dump objects in certain order so there won't be any loops.
> >   This property of process that dumpfile can in theory be O_APPEND, will likely be
> >   sacrifised (read: child can ptrace parent)
> 
> The ability to streamline the checkpoint image IMHO is invaluable.
> It's the unix way (TM) of doing things; it makes the process pipe-able.
> 
> You can do many nice things when the checkpoint can be streamed: you
> can compress, sign, encrypt etc on the fly without taking additional
> diskspace. You can transfer over the network (e.g. for migration),
> or store remotely without explicit file system support. You can easily
> transform the stream from one c/r version to another etc.
> 
> This should be a design principle. In my experience I never hit a wall
> that forced me to "sacrifice" this decision.
> 
> >   sacrifised (read: child can ptrace parent)
> 
> Hmmm... if all tasks are created in user space, then this specific
> becomes a no-brainer !

No!

A ptraces B. Container is checkpointed.

Kernel realizes ptrace is going on. A and B in theory can have any
realitionship.

Consequently, kernel doesn't know in which order to dump A and B.

And there is no such order:
*) A can be parent of B (you dump A, B),
*) A can be child of B (you want to dump B, A, but this conflicts with
   ->real_parent order)
*) A and B just tasks (any order).

I'm showing that whole issue can be avoided:
*) all tasks are simply created regardless of who is parent of whom
   (see kernel_thread())
*) Every task_struct image among other things contains references to
   ->real_parent and ->parent.
*) After every task is created it's time to change references:
	**) lookup who is ->real_parent, change ->real_parent _by hand_
		not with some "correct clone(2)" order.
	**) lookup who is ->parent, change ->parent.

You're probably escaping all of this with object numbers?
	
> > * add struct vm_operations_struct::checkpoint
> > 
> >   just like with files, code that creates special VMAs should know what to do with them
> >   used.
> > 
> >   just like with files, deny checkpointing by default
> > 
> >   So far used to install vDSO to same place.
> 
> VDSO can be a troublemaker; in recent kernels its location in the MM
> can be randomized.

See arch_setup_additional_pages() patch.

>  It is not necessarily immutable - it can reflect
> ynamic kernel data. It may contain different code on newer versions,
> so must be compared or worked around during restart etc.

i386 if I'm not mistaken only contain syscall entry code, but, yes,
generally one should check if PC is inside such page.

> > * add checkpoint(2)
> > 
> >   Done by determining which tasks are subject to checkpointing, freezeing them,
> >   collecting pointers to necessary kernel internals (task_struct, mm_struct, ...),
> >   doing that checking supported/unsupported status and aborting if necessary,
> >   actual dumping, unfreezeing/killing set of tasks.
> > 
> >   Also in-checkpoint refcount is maintained to abort on possible invisible changes.
> >   Now it works:
> > 
> > 	For every collected object (mm_struct) keep numbers of references from
> > 	other collected objects. It should match object's own refcount.
> > 	If there is a mismatch, something is likely pinning object, which means
> > 	there is "leak" to outside which means checkpoint(2) can't realistically and
> > 	without consequences proceed.
> > 
> > 	This is in some sense independent check. It's designed to protect from internals
> > 	change when C/R code was forgotten to be updated.
> > 
> >   Userpsace supplies pid of root task and opened file descriptor of future dump file.
> >   Kernel reports 0/-E as usual.
> > 
> >   Runtime tracking of "checkpointable" property is explicitly not done.
> >   This introduces overhead even if checkpoint(2) is not done as shown by proponents.
> >   Instead any check is done at checkpoint(2) time and -E is returned if something is
> >   suspicious or known to be unsupported.
> > 
> >   FIXME: more checks especially in cr_check_task_struct().
> > 
> > * add restart(2)
> > 
> >   Recreate tasks and evething dumped by checkpoint(2) as if nothing happened.
> > 
> >   The focus is on correct recreating, checking every possibility that target kernel
> >   can be on different arch (i386 => x86_64) and target kernel can be very different
> >   from source kernel by mistake (i386 => x86_64 COMPAT=n) kernel.
> > 
> >   restart(2) is done first by creating kernel thread and that demoting it to usual
> >   process by adding mm_struct, VMAs, et al. This saves time against method when
> >   userspace does fork(2)+restart(2) -- forked mm_struct will be thrown out anyway
> >   or at least everything will be unmapped in any case.
> 
> Do have figures to support your claims about "saves time" ?
> 
> The *largest* component of the restart time, as you probably know,
> is the time it takes to restore the memory address space (pages, pages)
> of the tasks.
> 
> If you do show that this optimization is worth our attention, then it
> takes < 10 lines to change current mktree.c to use CLONE_VM ... voila.
> 
> I'm interested in hearing more convincing arguments in favor of kernel
> creations of restarting tasks (see my other post about it).

OK, in another post.

> >   Restoration is done in current context except CPU registers at last stage.
> >   This is because "creation is done by current" is in many, many places,
> >    e.g. mmap(2) code.
> > 
> >   It's expected that filesystem state will be the same. Kernel can't do anything
> >   about it expect probably virtual filesystems. If a file is not there anymore,
> >   it's not kernel fault, -E will be returned, restart aborted.
> > 
> >   FIXME: errors aren't propagated correctly out of kernel thread context
> 
> Heh .. I guess they always propagate correctly out of regular task
> context ;)

:-) 
