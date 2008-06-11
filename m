From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Date: Wed, 11 Jun 2008 13:57:34 +0530
Message-ID: <484F8C76.4080300@linux.vnet.ibm.com>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830806110017t5ebeda78id1914d179a018422-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, "nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org" <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Thu, Jun 5, 2008 at 6:52 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>> Move Usage at Task Move (just an experimantal for discussion)
>> I tested this but don't think bug-free.
>>
>> In current memcg, when task moves to a new cg, the usage remains in the old cg.
>> This is considered to be not good.
> 
> Is it really such a big deal if we don't transfer the page ownerships
> to the new cgroup? As this thread has shown, it's a fairly painful
> operation to support. It would be good to have some concrete examples
> of cases where this is needed.
> 
> 

I tend to agree with Paul. One of the reasons, I did not move charges is that
makes migration an expensive operation. Since migration is well controlled with
permissions, we assume that the node owner what he/she is doing.

>> This is a trial to move "usage" from old cg to new cg at task move.
>> Finally, you'll see the problems we have to handle are failure and rollback.
>>
>> This one's Basic algorithm is
>>
>>     0. can_attach() is called.
>>     1. count movable pages by scanning page table. isolate all pages from LRU.
>>     2. try to create enough room in new memory cgroup
>>     3. start moving page accouing
>>     4. putback pages to LRU.
>>     5. can_attach() for other cgroups are called.
>>
>> A case study.
>>
>>  group_A -> limit=1G, task_X's usage= 800M.
>>  group_B -> limit=1G, usage=500M.
>>
>> For moving task_X from group_A to group_B.
>>  - group_B  should be reclaimed or have enough room.
>>
>> While moving task_X from group_A to group_B.
>>  - group_B's memory usage can be changed
>>  - group_A's memory usage can be changed
>>
>>  We accounts the resouce based on pages. Then, we can't move all resource
>>  usage at once.
>>
>>  If group_B has no more room when we've moved 700M of task_X to group_B,
>>  we have to move 700M of task_X back to group_A. So I implemented roll-back.
>>  But other process may use up group_A's available resource at that point.
>>
>>  For avoiding that, preserve 800M in group_B before moving task_X means that
>>  task_X can occupy 1600M of resource at moving. (So I don't do in this patch.)
> 
> I think that pre-reserving in B would be the cleanest solution, and
> would save the need to provide rollback.
> 
>>  2. Don't move any usage at task move. (current implementation.)
>>    Pros.
>>      - no complication in the code.
>>    Cons.
>>      - A task's usage is chareged to wrong cgroup.
>>      - Not sure, but I believe the users don't want this.
> 
> I'd say stick with this unless there a strong arguments in favour of
> changing, based on concrete needs.
> 
>> One reasone is that I think a typical usage of memory controller is
>> fork()->move->exec(). (by libcg ?) and exec() will flush the all usage.
> 
> Exactly - this is a good reason *not* to implement move - because then
> you drag all the usage of the middleware daemon into the new cgroup.
> 

Yes. The other thing is that charges will eventually fade away. Please see the
cgroup implementation of page_referenced() and mark_page_accessed(). The
original group on memory pressure will drop pages that were left behind by a
task that migrates. The new group will pick it up if referenced.

[snip]

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
