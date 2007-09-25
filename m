From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Tue, 25 Sep 2007 17:06:22 +0400
Message-ID: <46F907CE.1060807@openvz.org>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8E7AE.2090309@linux.vnet.ibm.com>
	<20070925202954.4e477564.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8F6FE.7040006@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F8F6FE.7040006-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> KAMEZAWA Hiroyuki wrote:
>> On Tue, 25 Sep 2007 16:19:18 +0530
>> Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>
>>> Hi, Kamezawa-San,
>>>
>> Hi,
>>
>>> Your changes make sense, but not CLUI (Command Line Usage) sense.
>>> 1. The problem is that when we mix strings with numbers, tools that
>>>    parse/use get confused and complicated
>> yes, maybe.
>>
>>> 2. ULONGLONG_MAX is a real limit, there is no such thing as unlimited.
>>>    If the user does ever go beyond ULONGLONG_MAX, we will limit him :-)
>>>
>> Oh. res_counter.c  uses LONGLONG_MAX as default value.
>> need fix ? or intended ?
> 
> Pavel do you remember why LONG was chosen instead of ULONG?

To prevent the overflow in "charge" routine.
See, if you add two numbers less than LONG_MAX, but with
unsigned long type each, you will never have an overflowed result.

>> And okay there is no "unlimited" state.
>>
>>> Having said that, I do wish to have a more intuitive interface for
>>> users. May be a perl/python script to hide away the numbers game
>>> from the users. What do you think?
>>>
>> I agree with you that perl/python script can hide details. but they need knowledge
>> about the maximum value, which is given as default value.
>>
>> In short, what I want is some value like RLIM_INFINITY in ulimit.
>>
> 
> I like the idea of RLIM_INFINITY and how ulimit as a tool shows
> a value. I guess we need something like RES_COUNTER_LIMIT_MAX
> and the user tool can show the limit as maximum. We could also
> define a special number, RES_COUNTER_LIMIT_INFINITY, such that
> containers will not enforce limits when the limit is set to
> this value.
> 
>> Because it seems that res_counter.c will be used for other resouce control purpose,
>> I thought some generic way (value) to know/specify "the maximum value" is helpful for
>> all resource controller interface.
>>
>> If there is an concensus that treaing ULONGLONG_MAX as default, it's ok.
>>
> 
> When I worked on the first version of res_counters, I used 0 to indicate
> unlimited. When Pavel posted his version, I think derived from
> beancounters, we did not want to have unlimited containers, so he used
> the maximum value

Yup! Setting LONGMAX pages for container means that this container
is unlimited, since there're no such many pages on any arch :)

>> Thanks,
>> -Kame
>>
> 
> Thanks for looking into this,
> 
