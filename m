From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 18/23] io-controller: blkio_cgroup patches from Ryo to
	track async bios.
Date: Wed, 2 Sep 2009 08:42:34 +0530
Message-ID: <661de9470909012012u4c4b5e50g816a524262642b1e__1054.46431921354$1251861295$gmane$org@mail.gmail.com>
References: <4A9C09BE.4060404@redhat.com> <20090831185640.GF3758@redhat.com>
	<e98e18940908311651s26de5b70ye6f4a82402956309@mail.gmail.com>
	<20090901.160004.226800357.ryov@valinux.co.jp>
	<20090901141142.GA13709@redhat.com>
	<20090902095912.cdf8a55e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090902095912.cdf8a55e.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Sep 2, 2009 at 6:29 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> On Tue, 1 Sep 2009 10:11:42 -0400
> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> > > > - Somebody also gave an example where there is a memory hogging pr=
ocess and
>> > > > =A0possibly pushes out some processes to swap. It does not sound f=
air to
>> > > > =A0charge those proccess for that swap writeout. These processes n=
ever
>> > > > =A0requested swap IO.
>> >
>> > I think that swap writeouts should be charged to the memory hogging
>> > process, because the process consumes more resources and it should get
>> > a penalty.
>> >
>>
>> A process requesting memory gets IO penalty? IMHO, swapping is a kernel
>> mechanism and kernel's way of providing extended RAM. If we want to solve
>> the issue of memory hogging by a process then right way to solve is to u=
se
>> memory controller and not by charging the process for IO activity.
>> Instead, proabably a more suitable way is to charge swap activity to root
>> group (where by default all the kernel related activity goes).
>>
>
> I agree. It't memcg's job.
> (Support dirty_ratio in memcg is necessary, I think)
>
> background-write-out-to-swap-for-memory-shortage should be handled
> as kernel I/O. If swap-out-by-memcg bacause of its limit is a problem,
> dirty_ratio for memcg should be implemetned.

I tend to agree, looks like dirty_ratio will become important along
with overcommit support in the future.

Balbir Singh.
