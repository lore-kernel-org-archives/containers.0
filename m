From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/5] Switch caches notification dynamically
Date: Mon, 01 Oct 2007 19:44:40 +0530
Message-ID: <470100D0.7030700@linux.vnet.ibm.com>
References: <46F91841.9070708@openvz.org> <46F919BB.2000701@openvz.org>
	<4700F2E8.5050904@linux.vnet.ibm.com> <4700F476.4070806@openvz.org>
	<4700F85B.5090902@linux.vnet.ibm.com> <4700FA0A.5040707@openvz.org>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4700FA0A.5040707-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
>>>>> +	if ((buf[0] == '1') && !(s->flags & SLAB_NOTIFY)) {
>>>> Won't this code break if I pass 10 as input in buf?
>>> I don't care about this :) And no /sys/slab/<xxx>/ file does.
>>> It's the problem of a user if he pass some shit and doesn't 
>>> see the notifications turned on/off ;)
>>>
>> Well, we don't want confused users? How does a user know what
>> is a valid value to pass? Are you saying that we don't need
> 
> The rules are simple - 1 to turn them on and 0 to turn them off
> and nothing more. These values user sees when he "cat"s this file.
> 

I think correct error reporting is critical, if the user sets
the value to 01 and that ends up disabling slab notifications,
the handling is wrong.

>> to care about user interface, if so I don't agree.
> 
> That's the convention used in the /sys/slab/<x>/ files - the
> 1 means on the 0 means 0, all the others are not guaranteed :)
> 

Is this documented somewhere or is this interpreted from looking
at the code of other file handlers?


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
