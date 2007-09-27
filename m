From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 2/3][NETNS45][V2] make timewait unhash lock free
Date: Thu, 27 Sep 2007 15:09:00 +0200
Message-ID: <46FBAB6C.6010908@fr.ibm.com>
References: <20070927110400.409277229@mai.toulouse-stg.fr.ibm.com>
	<20070927111212.651097600@mai.toulouse-stg.fr.ibm.com>
	<46FBA624.2070203@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46FBA624.2070203-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> Sorry for a delay in answer. A was ill last three days.
> Some stylistic comments inside
> 
> Daniel Lezcano wrote:
>> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>>
>> The network namespace cleanup will remove all timewait sockets
>> related to it because there are pointless. 
>>
>> The problem is we need to browse the established hash table and 
>> for that we need to take the lock. For each timesocket we call 
>> inet_deschedule and this one take the established hash table lock
>> too.
>>
>> The following patchset split the removing of the established hash
>> into two parts, one removing the node from the hash and another
>> taking the lock and calling the first one.
>>
>> The network namespace cleanup can be done calling the lock free
>> function.
>>
>> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>> ---
>>  include/net/inet_timewait_sock.h |   13 ++++++++++++
>>  net/ipv4/inet_timewait_sock.c    |   40 +++++++++++++++++++++++++++------------
>>  2 files changed, 41 insertions(+), 12 deletions(-)
>>
>> Index: linux-2.6-netns/net/ipv4/inet_timewait_sock.c
>> ===================================================================
>> --- linux-2.6-netns.orig/net/ipv4/inet_timewait_sock.c
>> +++ linux-2.6-netns/net/ipv4/inet_timewait_sock.c
>> @@ -13,25 +13,28 @@
>>  #include <net/inet_timewait_sock.h>
>>  #include <net/ip.h>
>>  
>> -/* Must be called with locally disabled BHs. */
>> -static void __inet_twsk_kill(struct inet_timewait_sock *tw,
>> -			     struct inet_hashinfo *hashinfo)
>> +static inline int inet_twsk_unehash(struct inet_timewait_sock *tw,
>> +				    struct inet_hashinfo *hashinfo)
>>  {
>> -	struct inet_bind_hashbucket *bhead;
>> -	struct inet_bind_bucket *tb;
>> -	/* Unlink from established hashes. */
>> -	struct inet_ehash_bucket *ehead = inet_ehash_bucket(hashinfo, tw->tw_hash);
>> +	struct inet_ehash_bucket *ehead =
>> +		inet_ehash_bucket(hashinfo, tw->tw_hash);
>>  
>>  	write_lock(&ehead->lock);
>> -	if (hlist_unhashed(&tw->tw_node)) {
>> +	if (__inet_twsk_unehash(tw)) {
>>  		write_unlock(&ehead->lock);
>> -		return;
>> +		return 1;
>>  	}
>> -	__hlist_del(&tw->tw_node);
>> -	sk_node_init(&tw->tw_node);
>>  	write_unlock(&ehead->lock);
>>  
>> -	/* Disassociate with bind bucket. */
>> +	return 0;
>> +}
> as far as I can understand the code, it will look better as below
> 
> struct inet_ehash_bucket *ehead =
>     inet_ehash_bucket(hashinfo, tw->tw_hash);
> int ret;
> 
> write_lock(&ehead->lock);
> ret = __inet_twsk_unehash(tw);
> write_unlock(&ehead->lock);
> return ret;

Right. Will fix that. Thanks.



[ cut ]
>> +
>>> see above about inet_twsk_unehash. We should insert
>         /* Disassociate with bind bucket. */
>>> here
>> +	return 0;
>> +}

Is this comment for me ?
