From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/23] io-controller: blkio_cgroup patches from Ryo to
	track async bios.
Date: Mon, 31 Aug 2009 14:56:40 -0400
Message-ID: <20090831185640.GF3758__17059.6149088398$1251745186$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<1251495072-7780-19-git-send-email-vgoyal@redhat.com>
	<4A9C09BE.4060404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A9C09BE.4060404-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 31, 2009 at 01:34:54PM -0400, Rik van Riel wrote:
> Vivek Goyal wrote:
>> o blkio_cgroup patches from Ryo to track async bios.
>>
>> o This functionality is used to determine the group of async IO from page
>>   instead of context of submitting task.
>>
>> Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
>> Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
>> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> This seems to be the most complex part of the code so far,
> but I see why this code is necessary.
>

Hi Rik,

Thanks for reviewing the patches. I wanted to have better understanding of
where all does it help to associate a bio to the group of process who
created/owned the page. Hence few thoughts.

When a bio is submitted to IO scheduler, it needs to determine the group
bio belongs to and group which should be charged to. There seem to be two 
methods.

- Attribute the bio to cgroup submitting process belongs to.
- For async requests, track the original owner hence cgroup of the page
  and charge that group for the bio. 

One can think of pros/cons of both the approaches.

- The primary use case of tracking async context seems be that if a
  process T1 in group G1 mmaps a big file and then another process T2 in
  group G2, asks for memory and triggers reclaim and generates writes of
  the file pages mapped by T1, then these writes should not be charged to
  T2, hence blkio_cgroup pages.

  But the flip side of this might be that group G2 is a low weight group
  and probably too busy also right now, which will delay the write out
  and possibly T2 will wait longer for memory to be allocated.

- At one point of time Andrew mentioned that buffered writes are generally a
  big problem and one needs to map these to owner's group. Though I am not
  very sure what specific problem he was referring to. Can we attribute
  buffered writes to pdflush threads and move all pdflush threads in a 
  cgroup to limit system wide write out activity?

- Somebody also gave an example where there is a memory hogging process and
  possibly pushes out some processes to swap. It does not sound fair to 
  charge those proccess for that swap writeout. These processes never
  requested swap IO.

- If there are multiple buffered writers in the system, then those writers
  can also be forced to writeout some pages to disk before they are
  allowed to dirty more pages. As per the page cache design, any writer
  can pick any inode and start writing out pages. So it can happen a
  weight group task is writting out pages dirtied by a lower weight group
  task. If, async bio is mapped to owner's group, it might happen that
  higher weight group task might be made to sleep on lower weight group
  task because request descriptors are all consumed up.

It looks like there does not seem to be a clean way which covers all the
cases without issues. I am just trying to think, what is a simple way
which covers most of the cases. Can we just stick to using submitting task
context to determine a bio's group (as cfq does). Which can result in
following.

- Less code and reduced complexity.

- Buffered writes will be charged to pdflush and its group. If one wish to
  limit buffered write activity for pdflush, one can move all the pdflush
  threads into a group and assign desired weight. Writes submitted in
  process context will continue to be charged to that process irrespective
  of the fact who dirtied that page.

- swap activity will be charged to kswapd and its group. If swap writes
  are coming from process context, it gets charged to process and its
  group. 

- If one is worried about the case of one process being charged for write
  out of file mapped by another process during reclaim, then we can
  probably make use of memory controller and mount memory controller and
  io controller together on same hierarchy. I am told that with memory
  controller, group's memory will be reclaimed by the process requesting
  more memory. If that's the case, then IO will automatically be charged
  to right group if we use submitting task context.

I just wanted to bring this point forward for more discussions to know
what is the right thing to do? Use bio tracking or not.

Ryo, any thoughts on this?

Thanks
Vivek

> Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
