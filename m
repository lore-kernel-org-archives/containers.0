From: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Subject: Re: Re: [RFC][PATCH 2/4] res_counter check usage under val
Date: Mon, 28 Jul 2008 17:28:58 +0900 (JST)
Message-ID: <26133366.1217233738316.kamezawa.hiroyu@jp.fujitsu.com>
References: <4884CA4F.9060003@openvz.org>
	<20080718193123.cf74b574.kamezawa.hiroyu@jp.fujitsu.com>
	<20080718193530.578fb1e3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4884CA4F.9060003-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

----- Original Message -----

>KAMEZAWA Hiroyuki wrote:
>> Add an interface to check usage is below "val"
>> 
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>> 
>>  include/linux/res_counter.h |   13 +++++++++++++
>>  1 file changed, 13 insertions(+)
>> 
>> Index: mmtom-stamp-2008-07-15-15-39/include/linux/res_counter.h
>> ===================================================================
>> --- mmtom-stamp-2008-07-15-15-39.orig/include/linux/res_counter.h
>> +++ mmtom-stamp-2008-07-15-15-39/include/linux/res_counter.h
>> @@ -191,4 +191,17 @@ static inline int res_counter_set_limit(
>>  	return ret;
>>  }
>>  
>> +static inline int res_counter_check_under_val(struct res_counter *cnt,
>> +	unsigned long long val)
>> +{
>> +	unsigned long flags;
>> +	int ret = 0;
>> +
>> +	spin_lock_irqsave(&cnt->flags, flags);
>
>Is this spilock protection *really* required? As far as I see
>from its usage it is racy itself wrt to res_counter update, so 
>this locking looks superfluous.
>
I get your point. Logically this lock is unnecessary.
(And seems this patch itself is buggy..(maybe refresh miss))

BTW, I'm sorry if I misunderstand. unsigned long long (on x86-32)
can be compared safely ? 

Thanks,
-Kame

>> +	if (cnt->usage < val)
>> +		ret = 1;
>> +	spin_unlock_irqrestore(&cnt->flags, flags);
>> +	return ret;
>> +}
>> +
>>  #endif
>> 
>> 
>
