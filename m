From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: net-2.6.25-netns branch on git.openvz.org
Date: Thu, 15 Nov 2007 14:31:48 +0100
Message-ID: <473C4A44.4040406@fr.ibm.com>
References: <473C35F1.9030901@sw.ru> <473C4301.6060507@fr.ibm.com>
	<473C48F0.3010909@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473C48F0.3010909-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Hi, All!
>>>
>>> I have ported what is ready to send to netdev to 2.6.25 and created
>>> appropriate branches on git.openvz.org, namely
>>> - net-2.6.25 aka Miller's 2.6.25 tree
>>> - net-2.6.25-netns with ready patches
>> resyncing ... thanks :)
>>
>> I will send in a few moments a first round for ipv6 taking into account
>> ip6_fib.
>>
>> There some other pending patches I will send, I hope before the end of
>> the week.
>>
>> I am a little lost with what we want to send for net-2.6.25. I mean we
>> planned to send af_unix, af_packet, af_netlink, af_inet and af_inet6.
> 
> I think that should behave like a small squaw eating the bear. Right now
> we _can_ send netlink preparatory work + PF_UNIX + PF_PACKET. This code
> is ready, functional and complete. Let's send it now to reduce amount of
> work for maintaining.

Agree.

>> What is the level of functionnality we want to provide with ipv4 and
>> ipv6. For example we have addresss autoconfiguration for ipv6, shall we
>> send it ?
> 
> after that, we can continue the work. I think that we can send all
> remaining IPv4 code after while in this cycle. The code has been
> significantly changed and porting/splitting/re-splitting takes longer
> than I have expected. All sysctl/sysfs handling is out of scope for me
> now and, I think, Dave is not a right person to accept this code.
> 
> It will be very good if we'll have functional IPv4 in this kernel. All
> other staff looks like a pure bonus. At least we should test and
> stabilize it.

The problem I have with ipv6 is that is sharing code with ipv4 namespace 
like net/core/neigh.c. So it is difficult to test ipv6 namespace without 
that.

Can I help with ipv4 ?
