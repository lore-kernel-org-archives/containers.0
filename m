From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v5][PATCH 6/8] Checkpoint/restart: initial documentation
Date: Mon, 15 Sep 2008 15:26:15 -0500
Message-ID: <20080915202615.GA28683__36293.1250631393$1221514525$gmane$org@us.ibm.com>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-7-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1221347167-9956-7-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Covers application checkpoint/restart, overall design, interfaces
> and checkpoint image format.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

This really should include your demo programs from your patch 0/9
announcement.

> ---
>  Documentation/checkpoint.txt |  207 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 207 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/checkpoint.txt
> 
> diff --git a/Documentation/checkpoint.txt b/Documentation/checkpoint.txt
> new file mode 100644
> index 0000000..6bf75ce
> --- /dev/null
> +++ b/Documentation/checkpoint.txt
> @@ -0,0 +1,207 @@
> +
> +	=== Checkpoint-Restart support in the Linux kernel ===
> +
> +Copyright (C) 2008 Oren Laadan
> +
> +Author:		Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> +
> +License:	The GNU Free Documentation License, Version 1.2
> +		(dual licensed under the GPL v2)
> +Reviewers:
> +
> +Application checkpoint/restart [CR] is the ability to save the state
> +of a running application so that it can later resume its execution
> +from the time at which it was checkpointed. An application can be
> +migrated by checkpointing it on one machine and restarting it on
> +another. CR can provide many potential benefits:
> +
> +* Failure recovery: by rolling back an to a previous checkpoint
> +
> +* Improved response time: by restarting applications from checkpoints
> +  instead of from scratch.
> +
> +* Improved system utilization: by suspending long running CPU
> +  intensive jobs and resuming them when load decreases.
> +
> +* Fault resilience: by migrating applications off of faulty hosts.
> +
> +* Dynamic load balancing: by migrating applications to less loaded
> +  hosts.
> +
> +* Improved service availability and administration: by migrating
> +  applications before host maintenance so that they continue to run
> +  with minimal downtime
> +
> +* Time-travel: by taking periodic checkpoints and restarting from
> +  any previous checkpoint.
> +
> +
> +=== Overall design
> +
> +Checkpoint and restart is done in the kernel as much as possible. The
> +kernel exports a relative opaque 'blob' of data to userspace which can
> +then be handed to the new kernel at restore time.  The 'blob' contains
> +data and state of select portions of kernel structures such as VMAs
> +and mm_structs, as well as copies of the actual memory that the tasks
> +use. Any changes in this blob's format between kernel revisions can be
> +handled by an in-userspace conversion program. The approach is similar
> +to virtually all of the commercial CR products out there, as well as
> +the research project Zap.
> +
> +Two new system calls are introduced to provide CR: sys_checkpoint and
> +sys_restart.  The checkpoint code basically serializes internal kernel
> +state and writes it out to a file descriptor, and the resulting image
> +is stream-able. More specifically, it consists of 5 steps:
> +  1. Pre-dump
> +  2. Freeze the container
> +  3. Dump
> +  4. Thaw (or kill) the container
> +  5. Post-dump
> +Steps 1 and 5 are an optimization to reduce application downtime:
> +"pre-dump" works before freezing the container, e.g. the pre-copy for
> +live migration, and "post-dump" works after the container resumes
> +execution, e.g. write-back the data to secondary storage.
> +
> +The restart code basically reads the saved kernel state and from a
> +file descriptor, and re-creates the tasks and the resources they need
> +to resume execution. The restart code is executed by each task that
> +is restored in a new container to reconstruct its own state.
> +
> +
> +=== Interfaces
> +
> +int sys_checkpoint(pid_t pid, int fd, unsigned long flag);
> +  Checkpoint a container whose init task is identified by pid, to the
> +  file designated by fd. Flags will have future meaning (should be 0
> +  for now).
> +  Returns: a positive integer that identifies the checkpoint image
> +  (for future reference in case it is kept in memory) upon success,
> +  0 if it returns from a restart, and -1 if an error occurs.
> +
> +int sys_restart(int crid, int fd, unsigned long flags);
> +  Restart a container from a checkpoint image identified by crid, or
> +  from the blob stored in the file designated by fd. Flags will have
> +  future meaning (should be 0 for now).
> +  Returns: 0 on success and -1 if an error occurs.
> +
> +Thus, if checkpoint is initiated by a process in the container, one
> +can use logic similar to fork():
> +	...
> +	crid = checkpoint(...);
> +	switch (crid) {
> +	case -1:
> +		perror("checkpoint failed");
> +		break;
> +	default:
> +		fprintf(stderr, "checkpoint succeeded, CRID=%d\n", ret);
> +		/* proceed with execution after checkpoint */
> +		...
> +		break;
> +	case 0:
> +		fprintf(stderr, "returned after restart\n");
> +		/* proceed with action required following a restart */
> +		...
> +		break;
> +	}
> +	...
> +And to initiate a restart, the process in an empty container can use
> +logic similar to execve():
> +	...
> +	if (restart(crid, ...) < 0)
> +		perror("restart failed");
> +	/* only get here if restart failed */
> +	...
> +
> +
> +=== Checkpoint image format
> +
> +The checkpoint image format is composed of records consistings of a
> +pre-header that identifies its contents, followed by a payload. (The
> +idea here is to enable parallel checkpointing in the future in which
> +multiple threads interleave data from multiple processes into a single
> +stream).
> +
> +The pre-header is defined by "struct cr_hdr" as follows:
> +
> +struct cr_hdr {
> +	__s16 type;
> +	__s16 len;
> +	__u32 id;
> +};
> +
> +Here, 'type' field identifies the type of the payload, 'len' tells its
> +length in bytes. The 'id' identifies the owner object instance. The
> +meaning of the 'id' field varies depending on the type. For example,
> +for type CR_HDR_MM, the 'id' identifies the task to which this MM
> +belongs. The payload also varies depending on the type, for instance,
> +the data describing a task_struct is given by a 'struct cr_hdr_task'
> +(type CR_HDR_TASK) and so on.
> +
> +The format of the memory dump is as follows: for each VMA, there is a
> +'struct cr_vma'; if the VMA is file-mapped, it is followed by the file
> +name. Following comes the actual contents, in one or more chunk: each
> +chunk begins with a header that specifies how many pages it holds,
> +then a the virtual addresses of all the dumped pages in that chunk,
> +followed by the actual contents of all the dumped pages. A header with
> +zero number of pages marks the end of the contents for a particular
> +VMA. Then comes the next VMA and so on.
> +
> +To illustrate this, consider a single simple task with two VMAs: one
> +is file mapped with two dumped pages, and the other is anonymous with
> +three dumped pages. The checkpoint image will look like this:
> +
> +cr_hdr + cr_hdr_head
> +cr_hdr + cr_hdr_task
> +	cr_hdr + cr_hdr_mm
> +		cr_hdr + cr_hdr_vma + cr_hdr + string
> +			cr_hdr_pgarr (nr_pages = 2)
> +			addr1, addr2
> +			page1, page2
> +			cr_hdr_pgarr (nr_pages = 0)
> +		cr_hdr + cr_hdr_vma
> +			cr_hdr_pgarr (nr_pages = 3)
> +			addr3, addr4, addr5
> +			page3, page4, page5
> +			cr_hdr_pgarr (nr_pages = 0)
> +		cr_hdr + cr_mm_context
> +	cr_hdr + cr_hdr_thread
> +	cr_hdr + cr_hdr_cpu
> +cr_hdr + cr_hdr_tail
> +
> +
> +=== Changelog
> +
> +[2008-Sep-11] v5:
> +  - Config is 'def_bool n' by default
> +  - Improve memory dump/restore code (following Dave Hansen's comments)
> +  - Change dump format (and code) to allow chunks of <vaddrs, pages>
> +    instead of one long list of each
> +  - Fix use of follow_page() to avoid faulting in non-present pages
> +  - Memory restore now maps user pages explicitly to copy data into them,
> +    instead of reading directly to user space; got rid of mprotect_fixup()
> +  - Remove preempt_disable() when restoring debug registers
> +  - Rename headers files s/ckpt/checkpoint/
> +  - Fix misc bugs in files dump/restore
> +  - Fix cleanup on some error paths
> +  - Fix misc coding style
> +
> +[2008-Sep-04] v4:
> +  - Fix calculation of hash table size
> +  - Fix header structure alignment
> +  - Use stand list_... for cr_pgarr
> +
> +[2008-Aug-20] v3:
> +  - Various fixes and clean-ups
> +  - Use standard hlist_... for hash table
> +  - Better use of standard kmalloc/kfree
> +
> +[2008-Aug-09] v2:
> +  - Added utsname->{release,version,machine} to checkpoint header
> +  - Pad header structures to 64 bits to ensure compatibility
> +  - Address comments from LKML and linux-containers mailing list
> +
> +[2008-Jul-29] v1:
> +In this incarnation, CR only works on single task. The address space
> +may consist of only private, simple VMAs - anonymous or file-mapped.
> +Both checkpoint and restart will ignore the first argument (pid/crid)
> +and instead act on themselves.
> -- 
> 1.5.4.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
