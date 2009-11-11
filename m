From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Update the UNIX buffer restore code to match the new
	format saved in the image file
Date: Wed, 11 Nov 2009 13:57:16 -0800
Message-ID: <87vdhgvi6b.fsf@caffeine.danplanet.com>
References: <1257878856-25520-1-git-send-email-danms@us.ibm.com>
	<1257878856-25520-4-git-send-email-danms@us.ibm.com>
	<20091111213851.GE8761@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091111213851.GE8761-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed\, 11 Nov 2009 15\:38\:51 -0600")
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

>> /* Make sure there's room in the send buffer */
>> sndbuf = sk->sk_sndbuf;
>> -	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < len) &&
>> +	if (((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < h->lin_len) &&
>> capable(CAP_NET_ADMIN))
>> -		sk->sk_sndbuf += len;
>> +		sk->sk_sndbuf += h->lin_len;
>> else
sk-> sk_sndbuf = sysctl_wmem_max;

SH> Can you explain what's going on here?

If we're trying to restore a buffer that is larger than the remaining
space in the buffer, then one of two things can happen:

1. You're privileged and we make the space you need
2. You're not privileged so we give you the benefit of the doubt and
   set the buffer limit to the system default

In the case of 2, if that system default still isn't enough then the
sendmsg() will fail like it normally would.

The reason for this is that the application could have loaded up its
legitimate buffer with data and then set the buffer limit low.  That
doesn't purge the data it already had buffered, it just limits how
much you can add to it.  So, in order to not fail a restart of such a
legitimate situation, we assume the system default instead of the
limit set by the user.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
