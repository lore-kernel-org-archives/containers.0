From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Date: Thu, 13 Mar 2008 11:56:58 +0300
Message-ID: <47D8EC5A.20907@openvz.org>
References: <47D16004.7050204@openvz.org> <20080312230541.CB9021E703D@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080312230541.CB9021E703D-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

YAMAMOTO Takashi wrote:
>> @@ -36,10 +37,26 @@ int res_counter_charge(struct res_counter *counter, unsigned long val)
>>  {
>>  	int ret;
>>  	unsigned long flags;
>> +	struct res_counter *c, *unroll_c;
>> +
>> +	local_irq_save(flags);
>> +	for (c = counter; c != NULL; c = c->parent) {
>> +		spin_lock(&c->lock);
>> +		ret = res_counter_charge_locked(c, val);
>> +		spin_unlock(&c->lock);
>> +		if (ret < 0)
>> +			goto unroll;
>> +	}
>> +	local_irq_restore(flags);
>> +	return 0;
>>  
>> -	spin_lock_irqsave(&counter->lock, flags);
>> -	ret = res_counter_charge_locked(counter, val);
>> -	spin_unlock_irqrestore(&counter->lock, flags);
>> +unroll:
>> +	for (unroll_c = counter; unroll_c != c; unroll_c = unroll_c->parent) {
>> +		spin_lock(&unroll_c->lock);
>> +		res_counter_uncharge_locked(unroll_c, val);
>> +		spin_unlock(&unroll_c->lock);
>> +	}
>> +	local_irq_restore(flags);
>>  	return ret;
>>  }
> 
> what prevents the topology (in particular, ->parent pointers) from
> changing behind us?

The res_counter client must provide this. Currently cgroup subsystem does this.

> YAMAMOTO Takashi
> 
