From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] IO Controller: Add per-device weight and ioprio_class
	handling
Date: Thu, 14 May 2009 09:02:05 +0800
Message-ID: <4A0B6D8D.6060202__6752.29048724777$1242263169$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A0A29B5.7030109@cn.fujitsu.com>
	<20090513152909.GD7696@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090513152909.GD7696-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Wed, May 13, 2009 at 10:00:21AM +0800, Gui Jianfeng wrote:
> 
> [..]
>> @@ -2137,7 +2366,7 @@ void elv_fq_unset_request_ioq(struct request_queue *q, struct request *rq)
>>  void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
>>  {
>>  	entity->ioprio = entity->new_ioprio;
>> -	entity->weight = entity->new_weight;
>> +	entity->weight = entity->new_weigh;
>>  	entity->ioprio_class = entity->new_ioprio_class;
>>  	entity->sched_data = &iog->sched_data;
>>  }
>> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
>> index db3a347..0407633 100644
>> --- a/block/elevator-fq.h
>> +++ b/block/elevator-fq.h
>> @@ -253,6 +253,14 @@ struct io_group {
>>  #endif
>>  };
>>  
>> +struct policy_node {
> 
> Would "io_policy_node" be better?

  Sure

> 
>> +	struct list_head node;
>> +	char dev_name[32];
>> +	void *key;
>> +	unsigned long weight;
>> +	unsigned long ioprio_class;
>> +};
>> +
>>  /**
>>   * struct bfqio_cgroup - bfq cgroup data structure.
>>   * @css: subsystem state for bfq in the containing cgroup.
>> @@ -269,6 +277,9 @@ struct io_cgroup {
>>  
>>  	unsigned long weight, ioprio_class;
>>  
>> +	/* list of policy_node */
>> +	struct list_head list;
>> +
> 
> How about "struct list_head policy_list" or "struct list_head io_policy"?

  OK

-- 
Regards
Gui Jianfeng
