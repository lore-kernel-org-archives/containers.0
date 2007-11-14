From: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Subject: Re: Re: [RFC][ for -mm] memory controller enhancements for NUMA
	[10/10] per-zone-lru
Date: Wed, 14 Nov 2007 19:29:02 +0900 (JST)
Message-ID: <22200238.1195036142565.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071114091138.30BA11CD65F@siro.lan>
	<20071114175737.d5066644.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071114091138.30BA11CD65F-Pcsii4f/SVk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org
List-Id: containers.vger.kernel.org

>> +struct mc_lru_head {
>> +	struct list_head active_list[MAX_NR_ZONES];
>> +	struct list_head inactive_list[MAX_NR_ZONES];
>> +};
>> +
>
>i guess
>	struct foo {
>		struct list_head active_list;
>		struct list_head inactive_list;
>	} lists[MAX_NR_ZONES];
>is better.
Ah, yes. I'll change this.


>> @@ -139,8 +144,20 @@ struct mem_cgroup {
>>  	 * Per zone statistics (used for memory reclaim)
>>  	 */
>>  	struct mem_cgroup_zonestat zstat;
>> +#ifndef CONFIG_NUMA
>> +	struct lru_head	local_head;
>> +#endif
>
>	struct mc_lru_head local_lru;
>
thanks, I'll do test with !CONFIG_NUMA in the next post.

>> +static int mem_cgroup_init_lru(struct mem_cgroup *mem)
>> +{
>> +	int zone;
>> +	mem->lrus[0] = &mem->local_lru;
>
>'zone' seems unused.

ok.

Thanks,
-Kame
