From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Sat, 23 Jul 2011 12:39:24 +0400
Message-ID: <4E2A88BC.5010804@parallels.com>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110723002558.GE16940-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/23/2011 04:25 AM, Matt Helsley wrote:
> On Fri, Jul 15, 2011 at 05:45:10PM +0400, Pavel Emelyanov wrote:
>> Hi guys!
>>
>> There have already been made many attempts to have the checkpoint/restore functionality
>> in Linux, but as far as I can see there's still no final solutions that suits most of
>> the interested people. The main concern about the previous approaches as I see it was
>> about - all that stuff was supposed to sit in the kernel thus creating various problems.
>>
>> I'd like to bring this subject back again proposing the way of how to implement c/r
>> mostly in the userspace with the reasonable help of a kernel.
>>
>>
>> That said, I propose to start with very basic set of objects to c/r that can work with
>>
>> * x86_64 tasks (subtree) which includes
>>    - registers
>>    - TLS
>>    - memory of all kinds (file and anon both shared and private)
> 
> Do mixes of 32 and 64-bit tasks present any problems with this
> method?

In theory - no. But in practice I didn't write the 32-bit support yet.

>> * open regular files
>> * pipes (with data in it)
>>
>> Core idea:
>>
>> The core idea of the restore process is to implement the binary handler that can execve-ute
>> image files recreating the register and the memory state of a task. Restoring the process 
> 
> I suspect this can be done with Oren's patches too using binfmt-misc -- without any binfmt
> kernel code.
> 
>> tree and opening files is done completely in the user space, i.e. when restoring the subtree
>> of processes I first fork all the tasks in respective order, then open required files and 
> 
> OK. Oren's code also forked all the tasks in userspace prior to completing the restart.
> 
>> then call execve() to restore registers and memory.
> 
> That's kind of neat, but won't this interfere with restoring O_CLOEXEC
> flags? (I also asked this in a reply to the TOOLS email)
> 
>>
>> The checkpointing process is quite simple - all we need about processes can be read from /proc
>> except for several things - registers and private memory. In current implementation to get 
> 
> I put this to Tejun as well: What about stuff like epoll sets? Sure, you
> can see the epoll fd in /proc/<pid>/fd, but you can't read it to tell
> which fds are in it. Worse, even if you got the fds from the epoll items
> via /proc, the way epoll holds onto them does not guarantee they'll refer
> to the files the set would actuall wait on.
> 
> As best I can tell you can't reliably checkpoint epoll sets from userspace.

With the existing interfaces - yes. My aim was to start the discussion whether we can
extend the kernel APIs to make it possible to do so.

> Then there's the matter of unlinked files. How do you plan to deal
> with those without kernel code?

You will have the same problem even with the c/r in the kernel. Frankly, I don't see
much difference in where to solve this one, can you elaborate?

>> them I introduce the /proc/<pid>/dump file which produces the file that can be executed by the
>> described above binfmt. Additionally I introduce the /proc/<pid>/mfd/ dir with info about
>> mappings. It is populated with symbolc links with names equal to vma->vm_start and pointing to
>> mapped files (including anon shared which are tmpfs ones). Thus we can open some task's
>> /proc/<pid>/mfd/<address> link and find out the mapped file inode (to check for sharing) and
>> if required map one and read the contents of anon shared memory.
> 
> Finally, I think there's substantial room here for quiet and subtle
> races to corrupt checkpoint images. If we add /proc interfaces only to
> find they're racy will we need to add yet more /proc interfaces to
> maintain backward compatibility yet fix the races? To get the locking
> that ensures a consistent subset of information with this /proc-based
> approach I think we'll frequently need to change the contents of
> existing /proc files.
> 
> Imagine trusting the output of top to exactly represent the state of
> your system's cpu usage. That's the sort of thing a piecemeal /proc
> interface gets us. You're asking us to trust that frequent checkpoints
> (say once every five minutes) of large, multiprocess, month-long
> program runs won't quietly get corrupted and will leave plenty of
> performance to not interfere with the throughput of the work.
> 
> A kernel syscall interface has a better chance of allowing us to fix
> races without changing the interface. We've fixed a few races with
> Oren's tree and none of them required us to change the output format.

If we all decide, that we do want to have the checkpoint/restart as all-in-kernel approach,
then OK. But my impression is - the community is not happy with it.

> Cheers,
> 	-Matt Helsley
> .
> 
