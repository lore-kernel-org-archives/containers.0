From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH -mm] cgroups: fix failure path in cgroup_write_event_control()
Date: Thu, 25 Feb 2010 08:43:48 +0800
Message-ID: <4B85C7C4.4040100@cn.fujitsu.com>
References: <4B849B73.1040106@cn.fujitsu.com> <cc557aab1002240528t28eae36dj976525be2fcf7246@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cc557aab1002240528t28eae36dj976525be2fcf7246@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Kirill A. Shutemov wrote:
> On Wed, Feb 24, 2010 at 5:22 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>> How to reproduce:
>>
>>  # mount -t cgroup -o memory xxx /cgroup
>>  # mkdir /cgroup/tmp
>>  # ./cgroup_event_listener /cgroup/tmp/cgroup.event_control abc
>>  ^C
>>  # rmdir /cgroup/tmp
>>  # cat /proc/cgroups | grep memory
>>  memory  2       2       1         (should be "2 1 1")
>>  # umount /cgroup
>>  (failed!)
>>
>> Using a single goto label to cleanup multi failure paths can
>> get things wrong quite easily, while multi labels makes the
>> code cleaner.
> 
> I disagree.
> It's easer to make mistake on changing code with multi failure
> paths, if you want to move a code within function.
> 

You've made 2 mistakes here (the other one was pointed out by
Paul), so I don't think you can claim the way you use is better.

When using a single label, each cleanup has to take care of 3
different cases:

1. the resource hasn't been allocated.
2. the resource has been allocated.
3. the allocation has failed.

And you have to be aware that some failures may affect the other
cleanups, for example you have to do this check:

	if (a != NULL && a->b != NULL)
		cleanup(b);

In fact, I hardly see a single label is used where there are more
than 2 resources need to be reclaimed in other parts of kernel
code.

See copy_process() in kernel/fork.c. This function has about
15 failure paths, and it's modified by various people frequently.
What a disaster it will be if you use a single label to do all
the cleanups here.
