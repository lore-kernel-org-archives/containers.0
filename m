From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 7/9] cr: checkpoint saved_auxv as u64s
Date: Tue, 09 Feb 2010 15:43:18 -0500
Message-ID: <4B71C8E6.2010009@cs.columbia.edu>
References: <1265680806-13295-1-git-send-email-serue@us.ibm.com>
	<1265680806-13295-8-git-send-email-serue@us.ibm.com>
	<4B71994E.10105@cs.columbia.edu>
	<20100209202035.GC29094@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100209202035.GC29094-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>>> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>>
>>> unsigned longs are not a good value to checkpoint between
>>> x86-32 and x86-64 32-bit tasks :)
>>>
>>> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  checkpoint/checkpoint.c        |    5 +--
>>>  checkpoint/memory.c            |   53 +++++++++++++++++++++++++++++++++++++--
>>>  checkpoint/restart.c           |    6 ++--
>>>  include/linux/checkpoint_hdr.h |    2 +-
>>>  4 files changed, 56 insertions(+), 10 deletions(-)
>> [...]
>>
>> Sketch for a sanity check:
>>
>>> +static int ckpt_read_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
>>> +{
>>> +	int i, ret;
>>> +	u64 *buf = kmalloc(CKPT_AT_SZ, GFP_KERNEL);
>>> +
>>> +	if (!buf)
>>> +		return -ENOMEM;
>>> +	ret = _ckpt_read_buffer(ctx, buf, CKPT_AT_SZ);
>>> +	if (ret < 0) {
>>> +		kfree(buf);
>>> +		return ret;
>>> +	}
>>> +
>> 	ret = -E2BIG;
>>> +	for (i=0; i<AT_VECTOR_SIZE; i++)
>>> +		if (buf[i] > (u64) ULONG_MAX)
>> 			goto out;
>>
>> 	ret = -EINVAL;
>> 	for (i=0; i<AT_VECTOR_SIZE; i++)
>> 		if (mm->saved_auxv[i] == AT_NULL)
>> 			ret = 0;
>> 	if (ret < 0)
>> 		goto out;
> 
> Yup, that would work.
> 
> Alternatively, do you think it would be safe to just
> always set the last entry to AT_NULL?

A bit hacky, but should work.
... so I'll do just that :)

Oren.

> 
>>> +
>>> +	for (i=0; i<AT_VECTOR_SIZE; i++)
>>> +		mm->saved_auxv[i] = buf[i];
>>> +
>>  out:
>>> +	kfree(buf);
>>> +	return 0;
>> 	       ret;
>>
>> [...]
>>
>> Oren.
> 
