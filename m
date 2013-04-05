From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 21/28] vmscan: also shrink slab in memcg pressure
Date: Fri, 5 Apr 2013 12:25:04 +0400
Message-ID: <515E8A60.3010203__22967.0511711904$1365150346$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-22-git-send-email-glommer@parallels.com>
	<CAFj3OHXp5K6TSCJq4gmi7Y_RpkmbLzDU3GP8vRMmChexULZjyQ@mail.gmail.com>
	<515C07E9.8080307@parallels.com>
	<CAFj3OHWEirUH-xWX4O1NVDXCc6EYtceYy9suUgphEQ3C-35oxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFj3OHWEirUH-xWX4O1NVDXCc6EYtceYy9suUgphEQ3C-35oxQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sha Zhengju <handai.szj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dave Shrinnker <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/04/2013 01:35 PM, Sha Zhengju wrote:
> On Wed, Apr 3, 2013 at 6:43 PM, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
>> On 04/03/2013 02:11 PM, Sha Zhengju wrote:
>>>>> +unsigned long
>>>>> +memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
>>>>> +{
>>>>> +       int nid = zone_to_nid(zone);
>>>>> +       int zid = zone_idx(zone);
>>>>> +       unsigned long val;
>>>>> +
>>>>> +       val = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL_FILE);
>>>>> +       if (do_swap_account)
>>> IMHO May get_nr_swap_pages() be more appropriate here?
>>>
>>
>> This is a per-memcg number, how would get_nr_swap_pages() help us here?
>>
> 
> I meant to add get_nr_swap_pages() as the if-judgement, that is:
>    if (do_swap_account && get_nr_swap_pages())
>        ....
> since anon pages becomes unreclaimable if swap space is used up.
> 
> 
Well, I believe this is doable.
