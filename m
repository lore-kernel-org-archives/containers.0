From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 08/28] list: add a new LRU list type
Date: Fri, 5 Apr 2013 12:01:01 +0400
Message-ID: <515E84BD.2080404__46500.1894663603$1365148872$gmane$org@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-9-git-send-email-glommer@parallels.com>
	<xr93ehepkcje.fsf@gthelen.mtv.corp.google.com>
	<20130405012048.GH12011@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130405012048.GH12011@dastard>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/05/2013 05:20 AM, Dave Chinner wrote:
> On Thu, Apr 04, 2013 at 02:53:49PM -0700, Greg Thelen wrote:
>> On Fri, Mar 29 2013, Glauber Costa wrote:
>>> From: Dave Chinner <dchinner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>> +long
>>> +list_lru_walk(
>>> +	struct list_lru *lru,
>>> +	list_lru_walk_cb isolate,
>>> +	void		*cb_arg,
>>> +	long		nr_to_walk)
>>> +{
>>> +	struct list_head *item, *n;
>>> +	long removed = 0;
>>> +restart:
>>> +	spin_lock(&lru->lock);
>>> +	list_for_each_safe(item, n, &lru->list) {
>>> +		int ret;
>>> +
>>> +		if (nr_to_walk-- < 0)
>>> +			break;
>>> +
>>> +		ret = isolate(item, &lru->lock, cb_arg);
>>> +		switch (ret) {
>>> +		case 0:	/* item removed from list */
>>> +			lru->nr_items--;
>>> +			removed++;
>>> +			break;
>>> +		case 1: /* item referenced, give another pass */
>>> +			list_move_tail(item, &lru->list);
>>> +			break;
>>> +		case 2: /* item cannot be locked, skip */
>>> +			break;
>>> +		case 3: /* item not freeable, lock dropped */
>>> +			goto restart;
>>
>> These four magic return values might benefit from an enum (or #define)
>> for clarity.
> 
> Obviously, and it was stated that this needed to be done by miself
> when I last posted the patch set many months ago. I've been rather
> busy since then, and so haven't had time to do anything with it.
> 
>> Maybe the names would be LRU_OK, LRU_REMOVED, LRU_ROTATE, LRU_RETRY.
> 
> Something like that...
> 
I can handle that and fold it with credits as usual if you don't mind.
