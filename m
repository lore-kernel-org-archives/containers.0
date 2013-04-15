From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v3 14/32] xfs: convert buftarg LRU to generic code
Date: Mon, 15 Apr 2013 06:14:44 -0400
Message-ID: <516BD314.9000302__37351.7004460611$1366020904$gmane$org@parallels.com>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
	<1365429659-22108-15-git-send-email-glommer@parallels.com>
	<xr9361zo8iav.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <xr9361zo8iav.fsf-aSPv4SP+Du0KgorLzL7FmE7CuiCeIGUxQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/15/2013 01:38 AM, Greg Thelen wrote:
> On Mon, Apr 08 2013, Glauber Costa wrote:
>
>> From: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>> Convert the buftarg LRU to use the new generic LRU list and take
>> advantage of the functionality it supplies to make the buffer cache
>> shrinker node aware.
>>
>> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>> Signed-off-by: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>> Conflicts with 3b19034d4f:
>> 	fs/xfs/xfs_buf.c
>> ---
>>   fs/xfs/xfs_buf.c | 167 +++++++++++++++++++++++++------------------------------
>>   fs/xfs/xfs_buf.h |   5 +-
>>   2 files changed, 79 insertions(+), 93 deletions(-)
>>
>> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
>> index 8459b5d..4cc6632 100644
>> --- a/fs/xfs/xfs_buf.c
>> +++ b/fs/xfs/xfs_buf.c
>> @@ -85,20 +85,14 @@ xfs_buf_vmap_len(
>>    * The LRU takes a new reference to the buffer so that it will only be freed
>>    * once the shrinker takes the buffer off the LRU.
>>    */
>> -STATIC void
>> +static void
>>   xfs_buf_lru_add(
>>   	struct xfs_buf	*bp)
>>   {
>> -	struct xfs_buftarg *btp = bp->b_target;
>> -
>> -	spin_lock(&btp->bt_lru_lock);
>> -	if (list_empty(&bp->b_lru)) {
>> -		atomic_inc(&bp->b_hold);
>> -		list_add_tail(&bp->b_lru, &btp->bt_lru);
>> -		btp->bt_lru_nr++;
>> +	if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru)) {
>>   		bp->b_lru_flags &= ~_XBF_LRU_DISPOSE;
>> +		atomic_inc(&bp->b_hold);
>>   	}
>> -	spin_unlock(&btp->bt_lru_lock);
>>   }
>>
>>   /*
>> @@ -107,24 +101,13 @@ xfs_buf_lru_add(
>>    * The unlocked check is safe here because it only occurs when there are not
>>    * b_lru_ref counts left on the inode under the pag->pag_buf_lock. it is there
>>    * to optimise the shrinker removing the buffer from the LRU and calling
>> - * xfs_buf_free(). i.e. it removes an unnecessary round trip on the
>> - * bt_lru_lock.
>> + * xfs_buf_free().
>>    */
>> -STATIC void
>> +static void
>>   xfs_buf_lru_del(
>>   	struct xfs_buf	*bp)
>>   {
>> -	struct xfs_buftarg *btp = bp->b_target;
>> -
>> -	if (list_empty(&bp->b_lru))
>> -		return;
>> -
>> -	spin_lock(&btp->bt_lru_lock);
>> -	if (!list_empty(&bp->b_lru)) {
>> -		list_del_init(&bp->b_lru);
>> -		btp->bt_lru_nr--;
>> -	}
>> -	spin_unlock(&btp->bt_lru_lock);
>> +	list_lru_del(&bp->b_target->bt_lru, &bp->b_lru);
>>   }
>>
>>   /*
>> @@ -151,18 +134,10 @@ xfs_buf_stale(
>>   	bp->b_flags &= ~_XBF_DELWRI_Q;
>>
>>   	atomic_set(&(bp)->b_lru_ref, 0);
>> -	if (!list_empty(&bp->b_lru)) {
>> -		struct xfs_buftarg *btp = bp->b_target;
>> -
>> -		spin_lock(&btp->bt_lru_lock);
>> -		if (!list_empty(&bp->b_lru) &&
>> -		    !(bp->b_lru_flags & _XBF_LRU_DISPOSE)) {
>> -			list_del_init(&bp->b_lru);
>> -			btp->bt_lru_nr--;
>> -			atomic_dec(&bp->b_hold);
>> -		}
>> -		spin_unlock(&btp->bt_lru_lock);
>> -	}
>> +	if (!(bp->b_lru_flags & _XBF_LRU_DISPOSE) &&
>> +	    (list_lru_del(&bp->b_target->bt_lru, &bp->b_lru)))
>> +		atomic_dec(&bp->b_hold);
>> +
>>   	ASSERT(atomic_read(&bp->b_hold) >= 1);
>>   }
>>
>> @@ -1498,83 +1473,95 @@ xfs_buf_iomove(
>>    * returned. These buffers will have an elevated hold count, so wait on those
>>    * while freeing all the buffers only held by the LRU.
>>    */
>> -void
>> -xfs_wait_buftarg(
>> -	struct xfs_buftarg	*btp)
>> +static int
>
> static enum lru_status
>

Uggh, I converted the inode and dcache and forgot to convert xfs. Thanks 
for spotting, Greg!
>
