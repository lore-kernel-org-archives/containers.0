From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: SNMP statistics in namespaces
Date: Tue, 26 Aug 2008 16:09:56 +0400
Message-ID: <48B3F294.7030007@openvz.org>
References: <C4D834D4.E6F9%echaudron@extremenetworks.com>
	<48B2C351.1090304@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B2C351.1090304-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: "Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Eelco Chaudron wrote:
>> Hi Dave,
>>
>> Guess it's useful when you are interested in network statistics per name space. I'm currently evaluating how much of the name space implementation we could use  in one of our projects (see my other email to the group).
>>
>> Any idea who might have a complete picture on the network name space project, and the overall status?
> 
> There is the overall status at:
> 
> http://lxc.sourceforge.net/network/status.php
> 
> AFAIR, Pavel Emylianov did some work on SNMP, I don't remember if he 
> told me it was finished or not.

SNMP for ipv4 is finished. Either Denis or me will do the same for
ipv6 in 2.6.28.

> Thanks.
> 
>> Thanks,
>>
>> Eelco
>>
>> On 8/22/08 5:20 PM, "Dave Hansen" <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>
>> On Fri, 2008-08-22 at 13:57 +0200, Eelco Chaudron wrote:
>>> I was looking at the 2.6.26 nw namespace code, and noticed that the
>>> SNMP counters are still system wide. Looking at the status page there
>>> is not separate item on SNMP. Was this overlooked, skipped on purpose,
>>> or is it in the pipeline?
>>>
>>> Hope some one can answer this...
>> I'm an idiot.  I know that SNMP has something to do with network
>> statistics, and I'm too lazy to google it.
>>
>> Could you give us a quick idea why SNMP is important here?  You're
>> welcome to add it to the list, but it's unlikely to get implemented
>> until someone thinks it is important.  That said, I'd be happy to help
>> you put together some patches to implement it.
>>
>> -- Dave
>>
>>
>>
>> ________________________________
>> DISCLAIMER:
>> This e-mail and any attachments to it may contain confidential and proprietary material and is solely for the use of the intended recipient. Any review, use, disclosure, distribution or copying of this transmittal is prohibited except by or on behalf of the intended recipient. If you have received this transmittal in error, please notify the sender and destroy this e-mail and any attachments and all copies, whether electronic or printed.
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
>>
> 
> 
