From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH -mm 2/6] introduce struct res_counter_ratelimit
Date: Fri, 19 Sep 2008 22:32:41 +0200
Message-ID: <48D40C69.8040207__22476.0280842476$1221856562$gmane$org@gmail.com>
References: <1221649528-8519-3-git-send-email-righi.andrea@gmail.com>
	<20080919100832.e188460a.randy.dunlap@oracle.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080919100832.e188460a.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Randy Dunlap wrote:
> On Wed, 17 Sep 2008 13:05:24 +0200 Andrea Righi wrote:
> 
>> Introduce res_counter_ratelimit as a generic structure to implement
>> throttling-based cgroup subsystems.
>>
>> [ Only the interfaces needed by the IO controller are implemented right now ]
>>
>> Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  include/linux/res_counter.h |   70 +++++++++++++++++++++++++
>>  kernel/res_counter.c        |  118 ++++++++++++++++++++++++++++++++++++++++++-
>>  2 files changed, 187 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index 0ab55c4..ff677d9 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -45,6 +46,38 @@ struct res_counter {
>>  	spinlock_t lock;
>>  };
>>  
>> +/* The various policies that can be used for throttling */
>> +#define	RATELIMIT_LEAKY_BUCKET	0
>> +#define	RATELIMIT_TOKEN_BUCKET	1
>> +
>> +struct res_counter_ratelimit {
>> +	/*
>> +	 * the current resource consumption level
>> +	 */
>> +	unsigned long long usage;
>> +	/*
>> +	 * the maximal value of the usage from the counter creation
>> +	 */
>> +	unsigned long long max_usage;
>> +	/*
>> +	 * the rate limit that cannot be exceeded
>> +	 */
>> +	unsigned long long limit;
>> +	/*
>> +	 * the limiting policy / algorithm
>> +	 */
>> +	unsigned long long policy;
>> +	/*
>> +	 * timestamp of the last accounted resource request
>> +	 */
>> +	unsigned long long timestamp;
>> +	/*
>> +	 * the lock to protect all of the above.
>> +	 * the routines below consider this to be IRQ-safe
>> +	 */
>> +	spinlock_t lock;
>> +};
> 
> With such nice struct comments, it looks like you should convert them
> to kernel-doc for structs.  See Documentation/kernel-doc-nano-HOWTO.txt
> for into, or ask me if you need some help with it.
> 

Sure! I will do for the next version. Actually, I'm already using the kernel-doc
style in other parts of this patchset (i.e. to document iothrottle structures).

Thanks!
-Andrea
