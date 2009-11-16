From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/4] Update the UNIX buffer restore code to match the
	new format saved in the image file
Date: Mon, 16 Nov 2009 13:35:09 -0500
Message-ID: <4B019B5D.1010905@cs.columbia.edu>
References: <1257878856-25520-1-git-send-email-danms@us.ibm.com>	<1257878856-25520-4-git-send-email-danms@us.ibm.com>	<20091111213851.GE8761@us.ibm.com>	<87vdhgvi6b.fsf@caffeine.danplanet.com>
	<20091112021824.GA14646@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091112021824.GA14646-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>>> /* Make sure there's room in the send buffer */
>>>> sndbuf = sk->sk_sndbuf;
>>>> -	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < len) &&
>>>> +	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < h->lin_len) &&
>>>> capable(CAP_NET_ADMIN))
>>>> -		sk->sk_sndbuf += len;
>>>> +		sk->sk_sndbuf += h->lin_len;
>>>> else
>> sk-> sk_sndbuf = sysctl_wmem_max;
>>
>> SH> Can you explain what's going on here?
>>
>> If we're trying to restore a buffer that is larger than the remaining
>> space in the buffer, then one of two things can happen:
>>
>> 1. You're privileged and we make the space you need
>> 2. You're not privileged so we give you the benefit of the doubt and
>>    set the buffer limit to the system default
>>
>> In the case of 2, if that system default still isn't enough then the
>> sendmsg() will fail like it normally would.
> 
> But so should check whether h->len_len < sysctl_wmem_max before
> doing the capable check?  Remember that any check for capable()
> will set PF_SUPERPRIV on the task, so it's better to not call it
> if it wasn't definately needed.
> 
>> The reason for this is that the application could have loaded up its
>> legitimate buffer with data and then set the buffer limit low.  That
>> doesn't purge the data it already had buffered, it just limits how
>> much you can add to it.  So, in order to not fail a restart of such a
>> legitimate situation, we assume the system default instead of the
>> limit set by the user.

Maybe also worth beefing up the comment near that code to help
future reviewers/developers...

The patch is good.

Oren
