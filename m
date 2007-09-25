From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Wed, 26 Sep 2007 00:51:59 +0530
Message-ID: <46F95FD7.3010204@linux.vnet.ibm.com>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8E7AE.2090309@linux.vnet.ibm.com>
	<20070925202954.4e477564.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8F6FE.7040006@linux.vnet.ibm.com> <46F907CE.1060807@openvz.org>
	<46F90DCA.5030209@linux.vnet.ibm.com> <46F90E48.6080603@openvz.org>
	<20070926000510.7d956db8.kamezawa.hiroyu@jp.fujitsu.com>
	<46F925ED.20303@openvz.org>
	<20070926003056.7df087a0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0709251205390.19001@chino.kir.corp.google.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.0.9999.0709251205390.19001-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

David Rientjes wrote:
> On Wed, 26 Sep 2007, KAMEZAWA Hiroyuki wrote:
> 
>>>> #define RES_COUNTER_INIFINITY 		(~0ULL)
>>>> or some nice name
>>> Why do we need this at all? We can simply push -1 there and be happy.
>>>
>> Hm, can this work now ?
>> ==
>> echo -1 > /cgroup/memory.limit_in_bytes
>> ==
>> Or users have to do following for unlimit resource ?
>> ==
>> echo some-very-very-big-number > /cgroup/memory.limit_in_bytes
>>
>>
>> I just think when some special value "-1" has a nice nick name, users will
>> be happy. If I'm a novice user, I don't imagine I can write -1 to limit value.
>> (but ok, tools can hide it for them.)
>>
> 
> Please simply use 0 to denote unconstrained memory, it's quite obvious 
> that nobody will sanely attach tasks to a cgroup that has no bytes of 
> memory allowed.
> 

Yes, I prefer 0 as well and had that in a series in the Lost World
of my earlier memory/RSS controller patches. I feel now that 0 is
a bit confusing, we don't use 0 to mean unlimited, unless we
treat the memory.limit_in_bytes value as boolean. 0 is false,
meaning there is no limit, > 0 is true, which means the limit
is set and the value is specified to the value read out.

> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -16,12 +16,15 @@
>  void res_counter_init(struct res_counter *counter)
>  {
>  	spin_lock_init(&counter->lock);
> -	counter->limit = (unsigned long)LONG_MAX;

So, we create all containers with infinite limit?

>  }
> 
>  int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>  {
> -	if (counter->usage + val > counter->limit) {
> +	/*
> +	 * If 'memory.limit' is set to 0, there is no charge to this

nit pick, should be memory.limit_in_bytes

> +	 * res_counter.
> +	 */
> +	if (counter->limit && counter->usage + val > counter->limit) {
>  		counter->failcnt++;
>  		return -ENOMEM;
>  	}


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
