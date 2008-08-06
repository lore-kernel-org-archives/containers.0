From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] CGROUPS: Group the CGROUPS Kconfig entries to be
	consecutive.
Date: Wed, 06 Aug 2008 16:50:02 +0530
Message-ID: <489988E2.70500@linux.vnet.ibm.com>
References: <alpine.LFD.1.10.0808041213540.2600@localhost.localdomain>
	<20080806130112.82c04664.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.1.10.0808060708450.25391@localhost.localdomain>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.LFD.1.10.0808060708450.25391-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Robert P. J. Day wrote:
> On Wed, 6 Aug 2008, KAMEZAWA Hiroyuki wrote:
> 
>> On Mon, 4 Aug 2008 12:16:05 -0400 (EDT)
>> "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org> wrote:
>>
>>> Move a few CGROUPS-related Kconfig entries so that they appear
>>> consecutively when running "make menuconfig."  This shouldn't affect
>>> the functionality.
>>>
>>> Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
>>>
>> Seems nice look. (Below is an menuconfig image, I modified a bit for -mm)
>>
>>     lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk x
>>   x x    --- Control Group support                                        x x
>>   x x    [ ]   Example debug cgroup subsystem                             x x
>>   x x    [*]   Namespace cgroup subsystem                                 x x
>>   x x    [ ]   Device controller for cgroups                              x x
>>   x x    [*]   Cpuset support                                             x x
>>   x x    [*]   Simple CPU accounting cgroup subsystem                     x x
>>   x x    [*]   Resource counters                                          x x
>>   x x    [*]     Memory Resource Controller for Control Groups            x x
>>   x x    [ ]   Memory resource limit controls for cgroups                 x x
>>
>> How do you think Paul ?
>>
>> Off-topic: to Balbir.
>>
>> How about "Aggregated Memory rlimit controls for cgroup" instead of
>> "Memory resource limit controls for cgroups" ?

Yes, we could do that. We can make it a menu when we add mlock control, etc.

> 
>   ok, i'll leave this with you and you can tweak and apply whatever
> suits you.

I like the way it looks as well.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
