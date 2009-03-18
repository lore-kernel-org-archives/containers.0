From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: C/R review
Date: Wed, 18 Mar 2009 06:19:37 -0400
Message-ID: <49C0CAB9.3080500__47498.5395129353$1237371958$gmane$org@cs.columbia.edu>
References: <20090317210110.GA3897@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090317210110.GA3897-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org



Alexey Dobriyan wrote:
> 	Low-level and high-level observations on the patch below.
> 	High-level thoughts at the end.

Thanks for the detailed review, Alexey.

> 
> 
>> +(2) Checkpoint image format
>> +
>> +The checkpoint image format is composed of records consisting of a
>> +pre-header that identifies its contents, followed by a payload. (The
>> +idea here is to enable parallel checkpointing in the future in which
>> +multiple threads interleave data from multiple processes into a single
>> +stream).
> 
> I have my doubts about parallel checkpoint especially how large container
> should be to need this and how much more complex code will it results in.

Doubts about the need ?   if I recall correctly IBM expressed interest in
checkpointing containers with hundreds/thousands of processes that are
spread among tens and hundreds of CPUs (multi-processor machine).

While I have not implemented it, I expect application downtime to improve
significantly using parallel checkpoint on a 4-cpu machine.

Doubts about the code complexity ?  no doubt .. it will be more complex ;)

> 
>> +The pre-header is defined by "struct cr_hdr" as follows:
>> +
>> +struct cr_hdr {
>> +	__s16 type;
> 
> OK, except 's' part. It's unneeded at all because type is a cookie.
> 
>> +	__s16 len;
> 
> OK, except potentially too small and 's' part.

Will fix.

> 
>> +	__u32 parent;
>> +};
>> +
>> +'type' identifies the type of the payload, 'len' tells its length in
>> +bytes, and 'parent' identifies the owner object instance. The meaning
>> +of 'parent' varies depending on the type. For example, for CR_HDR_MM,
>> +'parent' identifies the task to which this MM belongs.
> 
> mm_struct can belong to many tasks.

True. And because of that, it will only be saved once - when the first
task that uses it is found. So that is the 'parent' of the MM, in the
context of c/r.  During checkpoint, the other users of that MM will
skip it, and during restart they will plug-in the reconstructed MM.

> 
> This 'parent' is likely unneded because if object A refers to B
> (task_struct to mm_struct), image of A can very well include position of B
> in a dump file.

You are right.

The purpose of 'parent' is to point to the parent object, such that if
the data is sliced and interleaved (aka parallel checkpoint), we can
determine for each slice to which context/object it belongs.

> 
>> The payload
>> +also varies depending on the type, for instance, the data describing a
>> +task_struct is given by a 'struct cr_hdr_task' (type CR_HDR_TASK) and
>> +so on.
>> +
>> +The format of the memory dump is as follows: for each VMA, there is a
>> +'struct cr_vma'; if the VMA is file-mapped, it is followed by the file
>> +name. Following comes the actual contents, in one or more chunks: each
>> +chunk begins with a header that specifies how many pages it holds,
>> +then the virtual addresses of all the dumped pages in that chunk,
>> +followed by the actual contents of all the dumped pages. A header with
>> +zero number of pages marks the end of the contents for a particular
>> +VMA. Then comes the next VMA and so on.
> 
> This may be fine on current level but it's too unflexible on larger scale:
> kernel doesn't mess with filenames, it uses "struct file *". So, VMA should
> refer to struct file, and fd should refer to struct file and so on.

True - that's on the todo list.

> 
>> +(3) Shared resources (objects)
>> +
>> +Many resources used by tasks may be shared by more than one task (e.g.
>> +file descriptors, memory address space, etc), or even have multiple
>> +references from other resources (e.g. a single inode that represents
>> +two ends of a pipe).
>> +
>> +Clearly, the state of shared objects need only be saved once, even if
>> +they occur multiple times. We use a hash table (ctx->objhash) to keep
>> +track of shared objects and whether they were already saved.  Shared
>> +objects are stored in a hash table as they appear, indexed by their
>> +kernel address. (The hash table itself is not saved as part of the
>> +checkpoint image: it is constructed dynamically during both checkpoint
>> +and restart, and discarded at the end of the operation).
>> +
>> +Each shared object that is found is first looked up in the hash table.
>> +On the first encounter, the object will not be found, so its state is
>> +dumped, and the object is assigned a unique identifier and also stored
>> +in the hash table. Subsequent lookups of that object in the hash table
>> +will yield that entry, and then only the unique identifier is saved,
>> +as opposed the entire state of the object.
>> +
>> +During restart, shared objects are seen by their unique identifiers as
>> +assigned during the checkpoint. Each shared object that it read in is
>> +first looked up in the hash table. On the first encounter it will not
>> +be found, meaning that the object needs to be created and its state
>> +read in and restored. Then the object is added to the hash table, this
>> +time indexed by its unique identifier. Subsequent lookups of the same
>> +unique identifier in the hash table will yield that entry, and then
>> +the existing object instance is reused instead of creating another one.
> 
> OK, shared objects. I don't like "unique id" part. This unique id is position
> of an object in a dumpfile.
> 
>> +=== Overall design
> 
>> The
>> +kernel exports a relatively opaque 'blob' of data to userspace which can
>> +then be handed to the new kernel at restore time.  The 'blob' contains
>> +data and state of select portions of kernel structures such as VMAs
>> +and mm_structs, as well as copies of the actual memory that the tasks
>> +use. Any changes in this blob's format between kernel revisions can be
>> +handled by an in-userspace conversion program. The approach is similar
>> +to virtually all of the commercial C/R products out there, as well as
>> +the research project Zap.
>> +
>> +Two new system calls are introduced to provide C/R: sys_checkpoint()
>> +and sys_restart(). The checkpoint code basically serializes internal
>> +kernel state and writes it out to a file descriptor, and the resulting
>> +image is stream-able.
> 
> This is only so far and in theory. I _think_ we will end up with loops.

Can you elaborate ?

FYI, this is how Zap works, so far and in practice.

> 
>> +	===== Security consideration for Checkpoint-Restart =====
>> +
>> +The main question is whether sys_checkpoint() and sys_restart()
>> +require privileged or unprivileged operation.
>> +
>> +Early versions checked capable(CAP_SYS_ADMIN) assuming that we would
>> +attempt to remove the need for privilege, so that all users could
>> +safely use it. Arnd Bergmann pointed out that it'd make more sense to
>> +let unprivileged users use them now, so that we'll be more careful
>> +about the security as patches roll in.
>> +
>> +Checkpoint: the main concern is whether a task that performs the
>> +checkpoint of another task has sufficient privileges to access its
>> +state. We address this by requiring that the checkpointer task will be
>> +able to ptrace the target task, by means of ptrace_may_access() with
>> +read mode.
>> +
>> +Restart: the main concern is that we may allow an unprivileged user to
>> +feed the kernel with random data. To this end, the restart works in a
>> +way that does not skip the usual security checks. Task credentials,
>> +i.e. euid, reuid, and LSM security contexts currently come from the
>> +caller, not the checkpoint image.  When restoration of credentials
>> +becomes supported, then definitely the ability of the task that calls
>> +sys_restore() to setresuid/setresgid to those values must be checked.
>> +
>> +Keeping the restart procedure to operate within the limits of the
>> +caller's credentials means that there various scenarios that cannot
>> +be supported. For instance, a setuid program that opened a protected
>> +log file and then dropped privileges will fail the restart, because
>> +the user won't have enough credentials to reopen the file.
> 
> That's a bug.
> 
>> In these
>> +cases, we should probably treat restarting like inserting a kernel
>> +module: surely the user can cause havoc by providing incorrect data,
>> +but then again we must trust the root account.
>> +
>> +So that's why we don't want CAP_SYS_ADMIN required up-front. That way
>> +we will be forced to more carefully review each of those features.
> 
> Not having CAP_SYS_ADMIN on restart is one big security hole.
> 
> The problem is that set of states which is representable by dumpfile is much
> bigger than set of states which can end up in a dumpfile, so on restart one
> has to return -E ad infinitum to make them equal.

I beg to differ. If we don't escalate the privileges of the user, then the
restart can only do as much as the user would have been able to do otherwise,
because it all boils down to syscalls executed on behalf of the user's tasks.

Am I missing something ?

> 
>> --- /dev/null
>> +++ b/Documentation/checkpoint/usage.txt
>> @@ -0,0 +1,171 @@
>> +
>> +	===== How to use Checkpoint-Restart =====
>> +
>> +The API consists of two new system calls:
>> +
>> +* int sys_checkpoint(pid_t pid, int fd, unsigned long flag );
> 							     s
>> +    Checkpoint a container whose init task is identified by pid, to
>> +    the file designated by fd. 'flags' will have future meaning (must
>> +    be 0 for now).
>> +
>> +    Returns: a positive checkpoint identifier (crid) upon success, 0
>> +    if it returns from a restart, and -1 if an error occurs.
>> +
>> +    'crid' uniquely identifies a checkpoint image. For each checkpoint
>> +    the kernel allocates a unique 'crid', that remains valid for as
>> +    long as the checkpoint is kept in the kernel (for instance, when a
>> +    checkpoint, or a partial checkpoint, may reside in kernel memory).
> 
> Why would anyone want to do a partial thing?
> 
> Why would anyone wants to keep structures in memory after C is done?
> Tasks die or continue to execute. If they died, dumpfile should be closed,
> if they execute, you needlessly keep references to structures preventing
> them to be freed.

See for example: http://www1.cs.columbia.edu/~orenl/papers/asplos09-assure.pdf
To make a long story short: to build a self healing system, the application is
forced to take checkpoints at "rescue points" during its execution, and they are
discarded soon after if all works well; on the other hand, if something bad
happens (e.g. segfault, privilege escalation, etc), then the applications is
forced to restart from a suitable "rescue point", and there return a suitable
error. The end result is full recovery and immune against some bugs/attacks.

Now, for this to work on a real system, checkpoint must be blazing fast, and
restart must be also very fast. The only option is to keep the image in memory
(and it works well, since it's kept for a short time).

A "partial" checkpoint, if you will, is suitable here because you may want to
not c/r some resources (e.g. some socket connections) but keep the original
fd (connection) as is across rescue points.

Whether or not a chekcpoint in memory "needlessly keeps reference..." largely
depends on what you are trying to do. There are other uses to being able to
go a short time back in execution, including debugging, speculative execution,
model checking and software q/a and more.

> 
>> +* int sys_restart(int crid, int fd, unsigned long flags);
>> +
>> +    Restart a container from a checkpoint image that is read from the
>> +    blob stored in the file designated by fd. 'crid' will have future
>> +    meaning (must be 0 for now).
> 
> There should be none? nsproxies are anonymous, cgroups have names as strings.

I'm unsure what you mean by that -- none what ?

> 
>> 'flags' will have future meaning
>> +    (must be 0 for now).
>> +
>> +    The role of 'crid' is to identify the checkpoint image in the case
>> +    that it remains in kernel memory. This will be useful to restart
>> +    from a checkpoint image that remains in kernel memory.
> 
> 
>> +The granularity of a checkpoint usually is a whole container. The
>> +'pid' argument is interpreted in the caller's pid namespace. So to
>> +checkpoint a container whose init task (pid 1 in that pidns) appears
>> +as pid 3497 the caller's pidns, the caller must use pid 3497. Passing
>> +pid 1 will attempt to checkpoint the caller's container, and if the
>> +caller isn't privileged and init is owned by root, it will fail.
>> +
>> +If the caller passes a pid which does not refer to a container's init
>> +task, then sys_checkpoint() would return -EINVAL. (This is because
>> +with nested containers a task may belong to more than one container).
>> +
>> +We assume that during checkpoint and restart the container state is
>> +quiescent.
> 
> You, of course, can't depend on that.
> 

We can force it in the code, but we don't do it now.

However, the code is safe and won't crash if this doesn't hold. (Of
course, in that case the checkpoint image may be worth nothing).

>> During checkpoint, this means that all affected tasks are
>> +frozen (or otherwise stopped).
> 
> What's is about? They will be frozen.

As it is now, the code can be used to checkpoint a subtree of tasks,
not in a container, that are stopped (as in SIGSTOP), and in many
cases it will successfully restart later.

> 
>>  During restart, this means that all
>> +affected tasks are executing the sys_restart() call.
> 
> Sorry?
> 

The way restart works right now is by first creating all restarting tasks
in user space, and then each task calls sys_restart().

(OpenVZ's creates the tasks in the kernel, and have all of them call some
function to do the restart, which is equivalent to calling sys_restart()).

>>  In both cases,
>> +if there are other tasks possible sharing state with the container,
>> +they must not modify it during the operation. It is the reponsibility
>> +of the caller to follow this requirement.
> 
> Again, you can't rely on that.
> 
>> +If the assumption that all tasks are frozen and that there is no other
>> +sharing doesn't hold - then the results of the operation are undefined
>> +(just as, e.g. not calling execve() immediately after vfork() produces
>> +undefined results).
> 
> You should check and abort if something is leaked out.

Eventually, yes.

> 
>> In particular, either checkpoint will fail, or it
>> +may produce a checkpoint image that can't be restarted, or (unlikely)
>> +the restart may produce a container whose state does not match that of
>> +the original container.
> 
> That's a bug, I don't understanding why you're putting this on paper.

Because that's the current behavior - and until that is fixed, it should
be documented.

> 
>> +Here is a code snippet that illustrates how a checkpoint is initiated
>> +by a process in a container - the logic is similar to fork():
>> +	...
>> +	crid = checkpoint(1, ...);
>> +	switch (crid) {
>> +	case -1:
>> +		perror("checkpoint failed");
>> +		break;
>> +	default:
>> +		fprintf(stderr, "checkpoint succeeded, CRID=%d\n", ret);
>> +		/* proceed with execution after checkpoint */
>> +		...
>> +		break;
>> +	case 0:
>> +		fprintf(stderr, "returned after restart\n");
>> +		/* proceed with action required following a restart */
>> +		...
>> +		break;
>> +	}
>> +	...
>> +
>> +And to initiate a restart, the process in an empty container can use
>> +logic similar to execve():
>> +	...
>> +	if (restart(crid, ...) < 0)
>> +		perror("restart failed");
>> +	/* only get here if restart failed */
>> +	...
>> +
>> +Note, that the code also supports "self" checkpoint, where a process
>> +can checkpoint itself.
> 
> Interesting.
> 
>> This mode does not capture the relationships
>> +of the task with other tasks, or any shared resources. It is useful
>> +for application that wish to be able to save and restore their state.
>> +They will either not use (or care about) shared resources,
> 
> Shared resources will care about such task.
> 
> If there is SHM segment created by unrelated task, should it be dumped?
> It is reachable by tsk->nsproxy->ipc_ns.

I see two uses to "self" checkpoint as defined here. One in a manner
that is similar to the paper that I described above. Another, is as a
by-product of out work, where single process, simple applications can
leverage c/r functionality "for free".

Note that there is another notion of "self" in the code - that's a
checkpoint of an entire container that is initiated by a task within
that container. This is useful if, for example, you'd like to run a
daemon in the container that will periodically checkpoint everything.
The nice thing about this is that it gives you a "fork-like" semantics
where if you checkpoint and fail - you get an error, checkpoint and
succeed, you get a positive number, and when you come back from restart
you get a 0;  so based on the return value you can decide what to do
next.

> 
>> +struct cr_hdr_cpu {
>> +	/* see struct pt_regs (x86-64) */
>> +	__u64 r15;
>> +	__u64 r14;
>> +	__u64 r13;
>> +	__u64 r12;
>> +	__u64 bp;
>> +	__u64 bx;
>> +	__u64 r11;
>> +	__u64 r10;
>> +	__u64 r9;
>> +	__u64 r8;
>> +	__u64 ax;
>> +	__u64 cx;
>> +	__u64 dx;
>> +	__u64 si;
>> +	__u64 di;
>> +	__u64 orig_ax;
>> +	__u64 ip;
>> +	__u64 cs;
>> +	__u64 flags;
>> +	__u64 sp;
>> +	__u64 ss;
>> +
>> +	/* segment registers */
>> +	__u64 ds;
>> +	__u64 es;
>> +	__u64 fs;
>> +	__u64 gs;
> 
> These aren't 64-bit.
> 
>> +	/* debug registers */
>> +	__u64 debugreg0;
>> +	__u64 debugreg1;
>> +	__u64 debugreg2;
>> +	__u64 debugreg3;
>> +	__u64 debugreg4;
>> +	__u64 debugreg5;
> 
> 4 and 5 don't exist.
> 
>> +	__u64 debugreg6;
>> +	__u64 debugreg7;
> 
>> +static void cr_save_cpu_regs(struct cr_hdr_cpu *hh, struct task_struct *t)
>> +{
>> +	struct thread_struct *thread = &t->thread;
>> +	struct pt_regs *regs = task_pt_regs(t);
>> +
>> +	hh->bp = regs->bp;
>> +	hh->bx = regs->bx;
>> +	hh->ax = regs->ax;
>> +	hh->cx = regs->cx;
>> +	hh->dx = regs->dx;
>> +	hh->si = regs->si;
>> +	hh->di = regs->di;
>> +	hh->orig_ax = regs->orig_ax;
>> +	hh->ip = regs->ip;
>> +	hh->cs = regs->cs;
>> +	hh->flags = regs->flags;
>> +	hh->sp = regs->sp;
>> +	hh->ss = regs->ss;
>> +
>> +	hh->ds = regs->ds;
>> +	hh->es = regs->es;
> 
> Segments need little abstracting to support i386 => x86_64 migration.
> And TLS stuff as well, if I'm not mistaken.

People are still working on x86_64 support, let alone x86_32 => x86_64
migration. Can you send patches ?

> 
>> +static int cr_write_head(struct cr_ctx *ctx)
>> +{
>> +	struct cr_hdr h;
>> +	struct cr_hdr_head *hh = cr_hbuf_get(ctx, sizeof(*hh));
>> +	struct new_utsname *uts;
>> +	struct timeval ktv;
>> +	int ret;
>> +
>> +	h.type = CR_HDR_HEAD;
>> +	h.len = sizeof(*hh);
>> +	h.parent = 0;
>> +
>> +	do_gettimeofday(&ktv);
>> +
>> +	hh->magic = CHECKPOINT_MAGIC_HEAD;
>> +	hh->major = (LINUX_VERSION_CODE >> 16) & 0xff;
>> +	hh->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
>> +	hh->patch = (LINUX_VERSION_CODE) & 0xff;
> 
> There is one more .x level and arbitrary strings after that.
> 

This is mostly informative - we cannot base our compatibility decision
anyway on only these numbers. And we can add whatever fields are thought
to be useful.

>> +struct cr_hdr_head {
>> +	__u64 magic;
>> +
>> +	__u16 major;
>> +	__u16 minor;
>> +	__u16 patch;
>> +	__u16 rev;
>> +
>> +	__u64 time;	/* when checkpoint taken */
>> +	__u64 flags;	/* checkpoint options */
>> +
>> +	char release[__NEW_UTS_LEN];
>> +	char version[__NEW_UTS_LEN];
>> +	char machine[__NEW_UTS_LEN];
>> +} __attribute__((aligned(8)));
>> +
>> +struct cr_hdr_tail {
>> +	__u64 magic;
>> +} __attribute__((aligned(8)));
>> +
>> +struct cr_hdr_tree {
>> +	__u32 tasks_nr;
>> +} __attribute__((aligned(8)));
>> +
>> +struct cr_hdr_pids {
>> +	__s32 vpid;
>> +	__s32 vtgid;
>> +	__s32 vppid;
>> +} __attribute__((aligned(8)));
> 
> pids have many numbers assosiated with them.

You pgid and sid ?  on the todo list.

> 
>> +struct cr_hdr_mm {
>> +	__u32 objref;		/* identifier for shared objects */
>> +	__u32 map_count;
> 
> map count doesn't need to be saved, it will increase naturally duing
> VMA creation.

It's a matter of taste: do you loop until you get an "end of list"
record, or do you save the length and loop over that many records.

> 
>> +	__u64 start_code, end_code, start_data, end_data;
>> +	__u64 start_brk, brk, start_stack;
>> +	__u64 arg_start, arg_end, env_start, env_end;
> 
> OK.
> 
>> +} __attribute__((aligned(8)));
> 
> Regarding aligned((8)) everywhere.
> 
> This looks like like a dumb way to fix some bug which was needed earlier.
> 
> Does aligned((8)) forces identical layout on every arch? I don't think so, but this is
> everything we care about.

I believe it is sufficient to better supoprt migration between x86_32
and x86_64 (or other architectures that need to restart 32 bit apps
on a 64 bit system). Am I missing something ?

> 
>> +/* vma subtypes */
>> +enum vm_type {
>> +	CR_VMA_ANON = 1,
>> +	CR_VMA_FILE
> 
> Distinguishable by position of struct file or -1 or something.
> And doesn't force file image to be near as side effect.

This list will grow and make things more efficient and readable.

> 
>> +struct cr_hdr_vma {
>> +	__u32 vma_type;
>> +	__u32 _padding;
>> +
>> +	__u64 vm_start;
>> +	__u64 vm_end;
>> +	__u64 vm_page_prot;
>> +	__u64 vm_flags;
>> +	__u64 vm_pgoff;
>> +} __attribute__((aligned(8)));
>> +
>> +struct cr_hdr_pgarr {
>> +	__u64 nr_pages;		/* number of pages to saved */
>> +} __attribute__((aligned(8)));
>> +
>> +struct cr_hdr_files {
>> +	__u32 objref;		/* identifier for shared objects */
>> +	__u32 nfds;
>> +} __attribute__((aligned(8)));
>> +
>> +struct cr_hdr_fd_ent {
>> +	__u32 objref;		/* identifier for shared objects */
>> +	__s32 fd;
>> +	__u32 close_on_exec;
> 
> Too much for a bit.

Hehehe .. to be on the safe side .. you never know !
Actually, this is to ensure 64-bit alignment  :)

> 
>> +} __attribute__((aligned(8)));
>> +
>> +/* fd types */
>> +enum  fd_type {
>> +	CR_FD_FILE = 1,
>> +	CR_FD_DIR,
>> +};
>> +
>> +struct cr_hdr_fd_data {
> 
> This is misleading. Kernel knows about fds only near userspace boundary, the rest is struct file.
> 
>> +	__u16 fd_type;
> 
> fds don't have types, they're numbers to put it shortly. ;-)
> 
>> +	__u16 f_mode;
>> +	__u32 f_flags;
>> +	__u64 f_pos;
>> +	__u64 f_version;
> 
> What is this for?
> 

State of the struct_file.

>> +static inline loff_t file_pos_read(struct file *file)
>> +{
>> +	return file->f_pos;
>> +}
>> +
>> +static inline void file_pos_write(struct file *file, loff_t pos)
>> +{
>> +	file->f_pos = pos;
>> +}
> 
> I failed myself to understand need for this wrappers at all.
> 
> If dump is single-threaded, who is going to change f_pos under you?
> 
> I'm passing &file->f_pos to vfs_write().

Dump will hopefully become multi-threaded some day.

Actually, that's the way it's done elsewhere in the system, and that's
the say it was explicitly suggested by Linus.

> 
>> +#ifdef CONFIG_CHECKPOINT_RESTART
>> +	atomic_set(&tsk->may_checkpoint, atomic_read(&orig->may_checkpoint));
>> +#endif
>>  	return tsk;
> 
> You heards from me on these checks.

I personally agree. Others think differently.

> 
> Acceptable overhead is freezing tasks during checkpoint(2) and kernel size increase.
> This is doable as OpenVZ implementation demonstrated (even if bit-rotted).
> 
> If freeze is done separatedly, someone will fsckup and checkpoint live
> tasks with obvious (oopsable) consequences.

The current code is safe with respect to a container unfrozen during or
before checkpoint.

> 
> We discussed with Pavel a bit, restart(2) can have execve(2) like semantics:
> if successful, process which executed restart(2) becomes init of fresh
> container (one of task from the image, BTW), Pavel said this should simplify
> some ugly reparenting code.

Yes, that's yet another possibility. See also my previous response:
https://lists.linux-foundation.org/pipermail/containers/2009-March/016310.html

Oren.
