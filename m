From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Wed, 11 Jun 2008 18:43:38 +0530
Message-ID: <484FCF82.1050100@linux.vnet.ibm.com>
References: <20080611212126.317a95f7.d-nishimura@mtf.biglobe.ne.jp>
	<20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	<484F8C76.4080300@linux.vnet.ibm.com>
	<22652920.1213188663353.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <22652920.1213188663353.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org wrote:
> ----- Original Message -----
>> On Wed, 11 Jun 2008 13:57:34 +0530
>> Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>
>> (snip)
>>
>>>>>  2. Don't move any usage at task move. (current implementation.)
>>>>>    Pros.
>>>>>      - no complication in the code.
>>>>>    Cons.
>>>>>      - A task's usage is chareged to wrong cgroup.
>>>>>      - Not sure, but I believe the users don't want this.
>>>> I'd say stick with this unless there a strong arguments in favour of
>>>> changing, based on concrete needs.
>>>>
>>>>> One reasone is that I think a typical usage of memory controller is
>>>>> fork()->move->exec(). (by libcg ?) and exec() will flush the all usage.
>>>> Exactly - this is a good reason *not* to implement move - because then
>>>> you drag all the usage of the middleware daemon into the new cgroup.
>>>>
>>> Yes. The other thing is that charges will eventually fade away. Please see 
> the
>>> cgroup implementation of page_referenced() and mark_page_accessed(). The
>>> original group on memory pressure will drop pages that were left behind by 
> a
>>> task that migrates. The new group will pick it up if referenced.
>>>
>> Hum..
>> So, it seems that some kind of "Lazy Mode"(#3 of Kamezawa-san's)
>> has been implemented already.
>>
>> But, one of the reason that I think usage should be moved
>> is to make the usage as accurate as possible, that is
>> the size of memory used by processes in the group at the moment.
>>
>> I agree that statistics is not the purpose of memcg(and swap),
>> but, IMHO, it's useful feature of memcg.
>> Administrators can know how busy or idle each groups are by it.
>>
> One more point. This kinds of lazy "drop" approach canoot works well when
> there are mlocked processes. lazy "move" approarch is better if we do in lazy
> way. And how quickly they drops depends on vm.swappiness.
> 
> Anyway, I don't like complicated logic in the kernel.
> So, let's see how simple "move" can be implemented. Then, it will be just a
> trade-off problem, IMHO.
> If policy is fixed, implementation itself will not be complicated, I think.
> 

I agree with you that it is a trade-off problem and we should keep move as
simple as possible.



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
