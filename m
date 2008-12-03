From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] Unused check for thread group leader
	inmem_cgroup_move_task
Date: Thu, 4 Dec 2008 01:08:12 +0900 (JST)
Message-ID: <16817.10.75.179.62.1228320492.squirrel__3239.62134211815$1228320724$gmane$org@webmail-b.css.fujitsu.com>
References: <200811291259.27681.knikanth@suse.de>
	<20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
	<200812010951.36392.knikanth@suse.de>
	<20081201133030.0a330c7b.kamezawa.hiroyu@jp.fujitsu.com>
	<20081203134024.GD17701@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081203134024.GD17701-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
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
Cc: nikanth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Balbir Singh said:
>> On Mon, 1 Dec 2008 09:51:35 +0530
>> Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
>>
>> > Ok. Then should we remove the unused code which simply checks for
>> thread group
>> > leader but does nothing?
>> >
>> > Thanks
>> > Nikanth
>> >
>> Hmm, it seem that code is obsolete. thanks.
>> Balbir, how do you think ?
>>
>> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>>
>> Anyway we have to visit here, again.
>
> Sorry, I did not review this patch. The correct thing was nikanth did
> at first, move this to can_attach(). Why would we allow threads to
> exist in different groups, but still mark them as being accounted to
> the thread group leader.
>
Considering following case,

  # mount -t cgroup none /cgroup -t memory,cpuset
  # mkdir /cgroup/grpA/
  # echo 1 > /cgroup/grpA/memory.use_hierarchy
  # echo 1G > /cgroup/grpA/memory.limit_in_bytes
  # mkdir /cgroup/grpA/01
  # mkdir /cgroup/grpA/02
  limit grpA/01's cpu to 0
  limit grpA/02's cpu to 1

  Run multithread program under grpA and move threads to grpA/01, grpA/02
  if necessary to bind cpu.

Your "hierarchy" added this kind of flexibility and this is very useful.
And, of course, cgroup generic interface allows per-thread group attaching.

This is why I changed my mind and agreed to handle hierarchy management
under the kernel.

This can be an answer for use case to explain why thread-leader-check is
bad ? If we add limitation as "memcgroup should be mounted without
others",

And, if we only allows attaching thread-group-leader, how to migrate
multi-threaded program's all thread ?

I'm sorry I misunderstand something.

-Kame
