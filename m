From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/5] Setup the control group
Date: Mon, 01 Oct 2007 18:27:27 +0400
Message-ID: <470103CF.9050208@openvz.org>
References: <46F91841.9070708@openvz.org> <46F91A1E.2060303@openvz.org>
	<4700FAAC.2050004@linux.vnet.ibm.com> <4700FB72.5070409@openvz.org>
	<4701013A.3010307@linux.vnet.ibm.com> <47010169.5040102@openvz.org>
	<47010276.8060802@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47010276.8060802-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> Pavel Emelyanov wrote:
>> Balbir Singh wrote:
>>> Pavel Emelyanov wrote:
>>>>> Could we make the user interface similar to the one in the memory
>>>>> controller please! It would make it easier for users to configure
>>>>> and control both.
>>>> Do you mean by merging the similar code or by making them look like
>>>> the same? If the second, than can you point at least one difference
>>>> except for "usage" vs "usage_in_bytes" (and similar) naming?
>>>>
>>> I meant similar naming, it makes it is easier if the naming convention
>>> is the same.
>> Ok. It looks like the naming in the memcontrol.c has changed after I
>> copied it from there :)
>>
>> BTW, after Andrew accept these patches I think I will spend some time
>> thinking about how to consolidate the res_counter files.
>>
> 
> Yes, we need to do that. Paul Menage wanted to pull in resource counters

No, please, no :) Let's have them splitted apart. I think that the
resource counter abstraction can be used in other places than the
control groups...

> into cgroups. Also, I'd like to be able to share res_counters between
> container groups or at-least support a hierarchy. We could discuss this
> at that point and/or send out an RFC to get more comments.
> 
>> Thanks,
>> Pavel
> 
> 
