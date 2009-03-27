From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Can not remove the subdirectory in cgroup pseudo-filesystem
Date: Fri, 27 Mar 2009 11:06:36 +0800
Message-ID: <d95d44a20903262006y573c1cceya50eeb6d4af231e4@mail.gmail.com>
References: <d95d44a20903250924p2fb28afdq7ac47cac372c7de3@mail.gmail.com>
	<20090325163702.GA17626@us.ibm.com>
	<d95d44a20903251011u5786c780wb3a0a0cc3b759689@mail.gmail.com>
	<49CAD714.4080307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49CAD714.4080307-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Thank you,

when I mount all cgroup subsystem to cgroupfs, it mounts also
the ns_cgroup which blocks the adding new taskes into given
cgroup.

If I mount a single subsystem (such as a memory), it can work.


>> # mount -t cgroup cgroup /mnt/cgrp
>
> mount cgroupfs with all cgroup subsystems is not so sane IMO.
>
>> # cd /mnt/cgrp
>> # mkdir test
>> # echo $$ > test/tasks
>>
>> Then, I would like to add bash_B in this task group but
>> fail:
>>
>> # echo #(PID_OF_bash_B) >  test/tasks
>> -bash: echo: write error: Operation not permitted
>>
>
> That's because ns_cgroup is binded in this cgroup hierarchy, and
> it's ns_cgroup that prevents the task attaching, but a patch in
> -mm tree relaxes this check, and you won't see this restriction
> when using ns_cgroup.
>
