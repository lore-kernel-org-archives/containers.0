From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/5] Setup the control group
Date: Mon, 01 Oct 2007 19:51:42 +0530
Message-ID: <47010276.8060802@linux.vnet.ibm.com>
References: <46F91841.9070708@openvz.org> <46F91A1E.2060303@openvz.org>
	<4700FAAC.2050004@linux.vnet.ibm.com> <4700FB72.5070409@openvz.org>
	<4701013A.3010307@linux.vnet.ibm.com> <47010169.5040102@openvz.org>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47010169.5040102-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Balbir Singh wrote:
>> Pavel Emelyanov wrote:
>>>> Could we make the user interface similar to the one in the memory
>>>> controller please! It would make it easier for users to configure
>>>> and control both.
>>> Do you mean by merging the similar code or by making them look like
>>> the same? If the second, than can you point at least one difference
>>> except for "usage" vs "usage_in_bytes" (and similar) naming?
>>>
>> I meant similar naming, it makes it is easier if the naming convention
>> is the same.
> 
> Ok. It looks like the naming in the memcontrol.c has changed after I
> copied it from there :)
> 
> BTW, after Andrew accept these patches I think I will spend some time
> thinking about how to consolidate the res_counter files.
> 

Yes, we need to do that. Paul Menage wanted to pull in resource counters
into cgroups. Also, I'd like to be able to share res_counters between
container groups or at-least support a hierarchy. We could discuss this
at that point and/or send out an RFC to get more comments.

> Thanks,
> Pavel


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
