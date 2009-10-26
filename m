From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: do not hold mmap_sem while checkpointing vma's
Date: Mon, 26 Oct 2009 19:24:08 -0400
Message-ID: <4AE62F98.1080501@librato.com>
References: <1256509409-3866-1-git-send-email-orenl@librato.com>
	<20091026205236.GK31446@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091026205236.GK31446-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Sun, Oct 25, 2009 at 06:23:29PM -0400, Oren Laadan wrote:
>> This patch modifies the memory checkpoint code to _not_ hold the
>> mmap_sem while dumping out the vma's.
>>
>> The problem with holding the mmap_sem is that it first takes the
>> mmap_sem and then takes the file's inode semaphore. This violates the
>> normal locking order, e,g, when taking a page fault during a copyout,
>> which is inode sem and then the mmap_sem.
>>
>> Normally this reverse locking order won't cause a lockup because a the
>> output file for the checkpoint image isn't used by the checkpointee.
>> However, there a couple of cases where it may be a problem, e.g. when
>> some async-IO happens to complete and triggers a page fault at the
>> wrong time.
>>
>> This fixes complaints from the lockdep about this reverse ordering.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>> ---
>>  checkpoint/memory.c |  133 ++++++++++++++++++++++++++++++++++++---------------
>>  1 files changed, 94 insertions(+), 39 deletions(-)

[...]

>> @@ -1288,9 +1343,9 @@ static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
>>  		}
>>  		set_mm_exe_file(mm, file);
>>  	}
>> +	up_write(&mm->mmap_sem);
>>
>>  	ret = _ckpt_read_buffer(ctx, mm->saved_auxv, sizeof(mm->saved_auxv));
>> -	up_write(&mm->mmap_sem);
>>  	if (ret < 0)
>>  		goto out;
>>
>> -- 
> 
> At least in the restart path it's interesting to see how Alexey did it
> without mmap_sem, at least for part of it:
> 
> http://patchwork.kernel.org/patch/25337/
> 
> (search for kstate_restore_mm_struct())

He's allocating a new mm. And he must do so because all tasks in the
tree are created sharing their parent's mm (unless it's a thread).

> Is that a feasible and more-suitable approach for the initial portions
> of mm restore?

Feasible ?  yes.
More-suitable ?  why ?

In our case, processes (unless threads) already have their "new" mm,
so you are suggesting to drop it and allocate a new one.

I'm unsure what is the issue with the current approach.

Oren.
