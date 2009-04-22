From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Tue, 21 Apr 2009 20:10:56 -0700
Message-ID: <e98e18940904212010m5b2e00f9xda32cb2c9594ca29__7373.93220556459$1240370105$gmane$org@mail.gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<49DF1256.7080403@cn.fujitsu.com> <20090413130958.GB18007@redhat.com>
	<49EE895A.1060101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49EE895A.1060101-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 21, 2009 at 8:04 PM, Gui Jianfeng
<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Vivek Goyal wrote:
>> On Fri, Apr 10, 2009 at 05:33:10PM +0800, Gui Jianfeng wrote:
>>> Vivek Goyal wrote:
>>>> Hi All,
>>>>
>>>> Here is another posting for IO controller patches. Last time I had pos=
ted
>>>> RFC patches for an IO controller which did bio control per cgroup.
>>> =A0 Hi Vivek,
>>>
>>> =A0 I got the following OOPS when testing, can't reproduce again :(
>>>
>>
>> Hi Gui,
>>
>> Thanks for the report. Will look into it and see if I can reproduce it.
>
> =A0Hi Vivek,
>
> =A0The following script can reproduce the bug in my box.
>
> #!/bin/sh
>
> mkdir /cgroup
> mount -t cgroup -o io io /cgroup
> mkdir /cgroup/test1
> mkdir /cgroup/test2
>
> echo cfq > /sys/block/sda/queue/scheduler
> echo 7 > /cgroup/test1/io.ioprio
> echo 1 > /cgroup/test2/io.ioprio
> echo 1 > /proc/sys/vm/drop_caches
> dd if=3D1000M.1 of=3D/dev/null &
> pid1=3D$!
> echo $pid1
> echo $pid1 > /cgroup/test1/tasks
> dd if=3D1000M.2 of=3D/dev/null
> pid2=3D$!
> echo $pid2
> echo $pid2 > /cgroup/test2/tasks
>
>
> rmdir /cgroup/test1
> rmdir /cgroup/test2
> umount /cgroup
> rmdir /cgroup

Yes, this bug happens when we move a task from a cgroup to another
one, and delete the cgroup. Since the actual move to the new cgroup is
performed in a delayed fashion, if the cgroup is removed before
another request from the task is seen (and the actual move is
performed) , it results in a hit on BUG_ON. I am working on a patch
that will solve this problem and a few others; basically it would do
ref counting  for io_group structure. I am having a few problems with
it at the moment; will post the patch as soon as I can get it to work.

>
> --
> Regards
> Gui Jianfeng
>
>
>
>
