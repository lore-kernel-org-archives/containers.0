From: "Vladislav D. Buzov" <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
Date: Fri, 10 Jul 2009 11:01:47 -0700
Message-ID: <4A57820B.9070409__33112.2288866483$1247249334$gmane$org@embeddedalley.com>
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>
	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>
	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com>
	<20090708035252.GA3215@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090708035252.GA3215-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
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
Cc: Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> Polling is never good (from the power consumption and efficiency
> view point), unless by poll you mean select() and wait on events.
>   
Currently poll()/select() on a file descriptor are not supported by
cgroups. So now, it's up to user application to decide whether it's
going to periodically check memory usage or use blocking read to wait
for notification.
> Blocked read requires a dedicated thread, adding a select or some
> other notification mechanism allows the software to wait on several
> events at the same time.
>   
That's true. This is the next step to be implemented. For now I just
don't want to complicate this notification feature. There is a parallel
discussion about proper threshold implementation, which I'd like to
finish first and then look at possible options for a better notification
mechanism.

> Could you clarify the meaning of "not in use"
>   
The threshold represents the minimal number of bytes that should be
available under the memory controller limit before notification occurs.
For example:

limit=10M
threshold=1M
Notification fires when memory usage reaches 9M

> Could you please elaborate further, why would other mechanisms not
> work? Hint: please see cgroupstats.
>   
I'm not saying that other mechanisms (other than the cgroup files) are
not going to work. The cgroup files was chosen to communicate
notifications and the blocking read is the only useful method there.

>> +	/*
>> +	 * We check on the way in so we don't have to duplicate code
>> +	 * in both the normal and error exit path.
>> +	 */
>> +	mem_cgroup_notify_test_and_wakeup(mem, mem->res.usage + PAGE_SIZE,
>> +							mem->res.limit);
>> +
>>     
>
> I don't think it is a good idea to directly read out mem->res.*
> without any protection
>   
Why do I need to protect it here? I'm just reading values, not modifying
them. I don't have to worry if the values change after I read them, the
awaken thread will figure it out. Also, if I use res_counter interface
to read fields (res_counter_read_u64()) then it still doesn't provide
any protection.

However, I understand your concerns about data protection here and
below. In my previous email there was a discussion about moving
threshold support to the res_counter rather than keeping it in the
memory controller cgroup. I like that idea and currently working on
another patch that adds threshold support into the res_counter. It will
address all concerns about mutual exclusive access.

> Could you please use mem or memcg, since we've been using that as a
> standard convention in our code.
>   
Ok.
>   
>> +				       unsigned long long usage,
>> +				       unsigned long long limit)
>> +{
>> +	if (unlikely(usage == RESOURCE_MAX))
>>     
>
> I don't think it is a good idea to use unlikely since it is always
> likely for root to be at RESOURCE_MAX. Using likely/unlikely on user
> parameters IMHO is not a good idea.
>   
I agree.

> Again, I am confused about the mutual exclusion, what protects the new
> values being added.
>   
Ditto.

> Please use res_counter abstractions to read mem->res values
>   
Ok.
