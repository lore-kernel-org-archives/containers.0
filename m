From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: enclose arch_setup_additional_pages() call between
	#ifdefs
Date: Mon, 01 Mar 2010 14:09:33 -0500
Message-ID: <4B8C10ED.7070900@cs.columbia.edu>
References: <1267424889-31388-1-git-send-email-orenl@cs.columbia.edu>
	<20100301145813.GB6714@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100301145813.GB6714-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> Invocation of arch_setup_additional_pages() should occur only for
>> those architectures that provide it:
>>
>> #ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
>> ...
>> #endif
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> (one query below)
> 
>> ---
>>  mm/mmap.c |   15 +++++++++++++--
>>  1 files changed, 13 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 6aa606a..6aadf2e 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2394,17 +2394,28 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
>>  			    struct mm_struct *mm,
>>  			    struct ckpt_hdr_vma *h)
>>  {
>> +	int ret = 0;
>> +
>>  	/*
>>  	 * FIX:
>>  	 * Currently, we only handle VDSO/vsyscall special handling.
>>  	 * Even that, is very basic - call arch_setup_additional_pages
>>  	 * requiring the same mapping (start address) as before.
>>  	 */
>> +
>> +	if (h->vma_type != CKPT_VMA_VDSO)
>> +		return -EINVAL;
> 
> Well this really should just be a BUG_ON, right?  Since this only
> gets called for the VDSO restore_vma_ops.

Sure. Will fix and push.

Thanks,

Oren.

> 
>> +#ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
>>  #if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
> 
> (aside: I would have liked to make this more generic, but for reasons
> i never quite tracked down that didn't end up working, and x86 is the
> only one which defines compat_arch_setup_additional_pages())
> 
>>  	if (test_thread_flag(TIF_IA32))
>> -		return syscall32_setup_pages(NULL, h->vm_start, 0);
>> +		ret = syscall32_setup_pages(NULL, h->vm_start, 0);
>> +	else
>> +#endif
>> +	ret = arch_setup_additional_pages(NULL, h->vm_start, 0);
>>  #endif
>> -	return arch_setup_additional_pages(NULL, h->vm_start, 0);
>> +
>> +	return ret;
>>  }
>>  #else /* !CONFIG_CHECKPOINT */
>>  #define special_mapping_checkpoint NULL
>> -- 
>> 1.6.3.3
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
