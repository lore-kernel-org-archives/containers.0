From: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Subject: Re: Re: [RFC][ for -mm] memory controller enhancements for NUMA
	[1/10] record nid/zid on page_cgroup
Date: Wed, 14 Nov 2007 19:31:36 +0900 (JST)
Message-ID: <6333287.1195036296158.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071114092243.9331F1CD66B@siro.lan>
	<20071114174131.cf7c4aa6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071114092243.9331F1CD66B-Pcsii4f/SVk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

>> Index: linux-2.6.24-rc2-mm1/mm/memcontrol.c
>> ===================================================================
>> --- linux-2.6.24-rc2-mm1.orig/mm/memcontrol.c
>> +++ linux-2.6.24-rc2-mm1/mm/memcontrol.c
>> @@ -131,6 +131,8 @@ struct page_cgroup {
>>  	atomic_t ref_cnt;		/* Helpful when pages move b/w  */
>>  					/* mapped and cached states     */
>>  	int	 flags;
>> +	short	nid;
>> +	short	zid;

>are they worth to be cached?
>can't you use page_zonenum(pc->page)?
>
Maybe I can. I'll drop this and see what the whole code looks like.

Thanks,
-Kame
