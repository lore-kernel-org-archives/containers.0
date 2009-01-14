From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v12][PATCH 01/14] Create syscalls: sys_checkpoint,
	sys_restart
Date: Wed, 14 Jan 2009 17:31:54 -0500
Message-ID: <496E67DA.7050503__11854.5819925659$1231972606$gmane$org@cs.columbia.edu>
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu>
	<1230542187-10434-2-git-send-email-orenl@cs.columbia.edu>
	<20090114180441.GD21516@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090114180441.GD21516-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org



Balbir Singh wrote:
> * Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> [2008-12-29 04:16:14]:
> 
>> Create trivial sys_checkpoint and sys_restore system calls. They will
>> enable to checkpoint and restart an entire container, to and from a
>> checkpoint image file descriptor.
>>
>> The syscalls take a file descriptor (for the image file) and flags as
>> arguments. For sys_checkpoint the first argument identifies the target
>> container; for sys_restart it will identify the checkpoint image.
>>
>> A checkpoint, much like a process coredump, dumps the state of multiple
>> processes at once, including the state of the container. The checkpoint
>> image is written to (and read from) the file descriptor directly from
>> the kernel. This way the data is generated and then pushed out naturally
>> as resources and tasks are scanned to save their state. This is the
>> approach taken by, e.g., Zap and OpenVZ.
>>
>> By using a return value and not a file descriptor, we can distinguish
>> between a return from checkpoint, a return from restart (in case of a
>> checkpoint that includes self, i.e. a task checkpointing its own
>> container, or itself), and an error condition, in a manner analogous
>> to a fork() call.
>>
>> We don't use copyin()/copyout() because it requires holding the entire
> 
>               ^^^^^^^^^^^^^^^^^^^ Do you mean get_user_pages(),
> copy_to/from_user()?

Yes, I meant copy_to/from_user() ...

Oren.
