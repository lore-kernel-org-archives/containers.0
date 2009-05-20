From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 5/6] cr: restore file->f_cred
Date: Wed, 20 May 2009 11:26:49 -0400
Message-ID: <4A142139.4050703@cs.columbia.edu>
References: <20090519014446.GA28277@us.ibm.com>
	<20090519014546.GE28312@us.ibm.com>
	<4A141CEE.2080100@cs.columbia.edu>
	<20090520152527.GA28585@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090520152527.GA28585-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, alexey-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>
>> Serge E. Hallyn wrote:
>>> Ony seems useful if you're using coda or hppfs, but go ahead and
>>   ^^^
>>
>> (It is also used in some place under net/*...)
> 
> ok
> 
>>> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
>>> index 98fc0f7..2693a72 100644
>>> --- a/include/linux/checkpoint_hdr.h
>>> +++ b/include/linux/checkpoint_hdr.h
>>> @@ -341,6 +341,7 @@ struct ckpt_hdr_file {
>>>  	__u32 _padding;
>>>  	__u64 f_pos;
>>>  	__u64 f_version;
>>> +	__s32 f_credref;
>> This can replace the unused _padding field above ?
> 
> Oh, of course.
> 
>>>  } __attribute__((aligned(8)));
>>>  
>>>  struct ckpt_hdr_file_generic {
>> Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> Thanks - did you want me to send a new version, or will you apply the
> updated patch?

I just assumed there will be a next version of the series :p

Oren.
