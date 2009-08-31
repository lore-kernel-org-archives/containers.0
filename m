From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/23] io-controller: blkio_cgroup patches from Ryo to
	track async bios.
Date: Mon, 31 Aug 2009 16:51:25 -0700
Message-ID: <e98e18940908311651s26de5b70ye6f4a82402956309__48898.1791226708$1251762747$gmane$org@mail.gmail.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<1251495072-7780-19-git-send-email-vgoyal@redhat.com>
	<4A9C09BE.4060404@redhat.com> <20090831185640.GF3758@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090831185640.GF3758-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 31, 2009 at 11:56 AM, Vivek Goyal<vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Aug 31, 2009 at 01:34:54PM -0400, Rik van Riel wrote:
>> Vivek Goyal wrote:
>>> o blkio_cgroup patches from Ryo to track async bios.
>>>
>>> o This functionality is used to determine the group of async IO from pa=
ge
>>> =A0 instead of context of submitting task.
>>>
>>> Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
>>> Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
>>> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>
>> This seems to be the most complex part of the code so far,
>> but I see why this code is necessary.
>>
>
> Hi Rik,
>
> Thanks for reviewing the patches. I wanted to have better understanding of
> where all does it help to associate a bio to the group of process who
> created/owned the page. Hence few thoughts.
>
> When a bio is submitted to IO scheduler, it needs to determine the group
> bio belongs to and group which should be charged to. There seem to be two
> methods.
>
> - Attribute the bio to cgroup submitting process belongs to.
> - For async requests, track the original owner hence cgroup of the page
> =A0and charge that group for the bio.
>
> One can think of pros/cons of both the approaches.
>
> - The primary use case of tracking async context seems be that if a
> =A0process T1 in group G1 mmaps a big file and then another process T2 in
> =A0group G2, asks for memory and triggers reclaim and generates writes of
> =A0the file pages mapped by T1, then these writes should not be charged to
> =A0T2, hence blkio_cgroup pages.
>
> =A0But the flip side of this might be that group G2 is a low weight group
> =A0and probably too busy also right now, which will delay the write out
> =A0and possibly T2 will wait longer for memory to be allocated.
>
> - At one point of time Andrew mentioned that buffered writes are generall=
y a
> =A0big problem and one needs to map these to owner's group. Though I am n=
ot
> =A0very sure what specific problem he was referring to. Can we attribute
> =A0buffered writes to pdflush threads and move all pdflush threads in a
> =A0cgroup to limit system wide write out activity?
>
> - Somebody also gave an example where there is a memory hogging process a=
nd
> =A0possibly pushes out some processes to swap. It does not sound fair to
> =A0charge those proccess for that swap writeout. These processes never
> =A0requested swap IO.
>
> - If there are multiple buffered writers in the system, then those writers
> =A0can also be forced to writeout some pages to disk before they are
> =A0allowed to dirty more pages. As per the page cache design, any writer
> =A0can pick any inode and start writing out pages. So it can happen a
> =A0weight group task is writting out pages dirtied by a lower weight group
> =A0task. If, async bio is mapped to owner's group, it might happen that
> =A0higher weight group task might be made to sleep on lower weight group
> =A0task because request descriptors are all consumed up.
>
> It looks like there does not seem to be a clean way which covers all the
> cases without issues. I am just trying to think, what is a simple way
> which covers most of the cases. Can we just stick to using submitting task
> context to determine a bio's group (as cfq does). Which can result in
> following.
>
> - Less code and reduced complexity.
>
> - Buffered writes will be charged to pdflush and its group. If one wish to
> =A0limit buffered write activity for pdflush, one can move all the pdflush
> =A0threads into a group and assign desired weight. Writes submitted in
> =A0process context will continue to be charged to that process irrespecti=
ve
> =A0of the fact who dirtied that page.

What if we wanted to control buffered write activity per group? If a
group keeps dirtying pages, we wouldn't want it to dominate the disk
IO capacity at the expense of other cgroups (by dominating the writes
sent down by pdflush).

>
> - swap activity will be charged to kswapd and its group. If swap writes
> =A0are coming from process context, it gets charged to process and its
> =A0group.
>
> - If one is worried about the case of one process being charged for write
> =A0out of file mapped by another process during reclaim, then we can
> =A0probably make use of memory controller and mount memory controller and
> =A0io controller together on same hierarchy. I am told that with memory
> =A0controller, group's memory will be reclaimed by the process requesting
> =A0more memory. If that's the case, then IO will automatically be charged
> =A0to right group if we use submitting task context.
>
> I just wanted to bring this point forward for more discussions to know
> what is the right thing to do? Use bio tracking or not.
>
> Ryo, any thoughts on this?
>
> Thanks
> Vivek
>
>> Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
