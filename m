From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Wed, 30 Jul 2008 14:22:26 -0400
Message-ID: <4890B162.9050405@cs.columbia.edu>
References: <Pine.LNX.4.64.0807292325290.9868@takamine.ncl.cs.columbia.edu>
	<20080730132257.9DF2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080730132257.9DF2.KOSAKI.MOTOHIRO-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



KOSAKI Motohiro wrote:
> Hi
> 
>> Expand the template sys_checkpoint and sys_restart to be able to dump
>> and restore a single task. The task's address space may consist of only
>> private, simple vma's - anonymous or file-mapped.
>>
>> This big patch adds a mechanism to transfer data between kernel or user
>> space to and from the file given by the caller (sys.c), alloc/setup/free
>> of the checkpoint/restart context (sys.c), output wrappers and basic
>> checkpoint handling (checkpoint.c), memory dump (ckpt_mem.c), input
>> wrappers and basic restart handling (restart.c), and finally the memory
>> restore (rstr_mem.c).
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> please write a documentation of describe memory dump file format,
> and split save and restore to two patches.

While save and restore functionality is already split to different source
files, I can easily refine the patch.

Dump file format: as agreed during the OLS, the format will be nested (as
in "depth-first" as opposed to "breadth-first"). The rationale is to be
able to stream the entire checkpoint image without file seeks. The suggested
layout looks like this:

1. Image header: information about kernel version, CR version, kernel
configuration, CPU capabilities etc.

2. Container global section: state that is global to the container, e.g.
SysV IPC, network setup.

3. Task tree/forest state: number of tasks and their relationships

4. State of each task (one by one): including task_struct state, thread
state, cpu registers, followed by memory, files, signals etc.

5. Image trailer: marking the end of the image and providing checksum and
the like.

Since this patch is only a proof-of-concept, it has a very simple #1,
no #2 or #3, limited #4 and very simple #5.

This patch still doesn't handle shared objects, but they will be handled
as follows: the first time a shared object is accessed (to dump it) it is
given a unique identifier and dumped in full. The next time(s) the object
is found, only the identifier is saved instead.

A bit more specific about the format: it will be composed of "records",
such that each record has a pre-header that identifies its contents and a
payload. (The idea here is to enable parallel checkpointing in the future
in which multiple threads interleave data from multiple processes into
a single stream).

The pre-header is:

struct cr_hdr {
	__s16 type;
	__s16 len;
	__u32 id;
};

'type' identified the type of the following payload, 'len' tells its length.
The 'id' identifies the object instance to which it belongs (it is currently
unused). The meaning of the 'id' field may vary depending on the type. For
example, for type CR_HDR_MM, the 'id' will identify the task to which this
MM belongs. The payload varies depending on its type, for instance, the data
describing a task_struct is given by a 'struct cr_hdr_task' (type CR_HDR_TASK)
and so on.

The format of the memory dump is slightly different: for each vma, there is
a 'struct cr_vma'; if the vma is file-mapped, it will be followed by the file
name. The cr_vma->npages will tell how many pages were dumped for this vma.
Then it will be followed by the actual data: first a dump of the addresses of
all dumped pages (npages entries) followed by a dump of the contents of all
dumped pages (npages pages). Then will come the next vma and so on.

For a single simple task, the format of the resulting checkpoint image would
look like this (assume 2 vma's, one file mapped with 2 dumped pages and the
other anonymous with 3 dumped pages):

cr_hdr + cr_hdr_head
cr_hdr + cr_hdr_task
	cr_hdr + cr_hdr_mm
		cr_hdr + cr_hdr_vma + cr_hdr + string
			addr1, addr2
			page1, page2
		cr_hdr + cr_hdr_vma
			addr3, addr4, addr5
			page3, page4, page5
		cr_hdr + cr_mm_context
	cr_hdr + cr_hdr_thread
	cr_hdr + cr_hdr_cpu
cr_hdr + cr_hdr_tail

Will add this documentation to the next version of the patch.

Oren.
