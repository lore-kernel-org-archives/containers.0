From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC PATCH] Make AT_VECTOR_SIZE_ARCH 2 for x86-32
Date: Mon, 08 Feb 2010 17:04:35 -0500
Message-ID: <4B708A73.9010306@cs.columbia.edu>
References: <20100208203440.GA27389@us.ibm.com>
	<20100208204837.GA27904@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100208204837.GA27904-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> [ RFC:  Am I on crack? ]
>>
>> Both x86-32 and x86-64 with 32-bit compat use ARCH_DLINFO_IA32,
>> which defines two saved_auxv entries.  But system.h only defines
>> AT_VECTOR_SIZE_ARCH as 2 for CONFIG_IA32_EMULATION, not for
>> CONFIG_X86_32.  Fix that.
> 
> To be clear, this patch if right would be for pushing upstream
> immediately.  It still leaves open the question of what we want
> to do about saved_auxv.  We currently just write it out as a
> buffer, but since it is actually an array of longs, and therefore
> differently sized on x86-32 and x86-64-compat, we would need to
> write them out entry-by-entry (and validate no overflows for
> TIF_IA32 tasks).  Does that seem warranted?

Yes: iterate over entries and copy them.

 From a brief look at the code, I don't think the contents of the
saved_auxv is used anywhere inside the kernel (it's exported via
/proc), except for the reliance on a trailing AT_NULL record
which is easy to test for.

Would it be wrong or insecure to export whatever garbage the user
may have put in that array (assuming it is null terminated) ?

Oren.


> 
>> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> ---
>>  arch/x86/include/asm/system.h |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/system.h b/arch/x86/include/asm/system.h
>> index ecb544e..e04740f 100644
>> --- a/arch/x86/include/asm/system.h
>> +++ b/arch/x86/include/asm/system.h
>> @@ -11,9 +11,9 @@
>>  #include <linux/irqflags.h>
>>
>>  /* entries in ARCH_DLINFO: */
>> -#ifdef CONFIG_IA32_EMULATION
>> +#if defined(CONFIG_IA32_EMULATION) || !defined(CONFIG_X86_64)
>>  # define AT_VECTOR_SIZE_ARCH 2
>> -#else
>> +#else /* else it's non-compat x86-64 */
>>  # define AT_VECTOR_SIZE_ARCH 1
>>  #endif
>>
>> -- 
>> 1.6.0.4
>>
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
