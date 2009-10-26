From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: do not hold mmap_sem while checkpointing vma's
Date: Mon, 26 Oct 2009 13:39:14 -0400
Message-ID: <4AE5DEC2.5090904@librato.com>
References: <1256509409-3866-1-git-send-email-orenl@librato.com>
	<20091026172423.GG23564@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091026172423.GG23564-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
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
> ...
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
> 
> Could there be a race here?  (If only with someone reading /proc/PID/auxv
> while this is happening, though maybe with another task sharing the mm at
> restart)  I wonder whether you should read into a tmpbuf without mm->mmap_sem,
> then re-acquire and write into mm->saved_auxv?

There is a race, but it is a harmless race: a user who does weird
things will get weird results (*).

Note that proc_pid_auxv() does not take the mmap_sem anyway.

If another process shared mm with a restarting task, then that other
process will crash soon after the mm is restored (see *).

Oren.
