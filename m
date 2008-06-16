From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Mon, 16 Jun 2008 15:07:07 +0800
Message-ID: <4856111B.4000106@cn.fujitsu.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <1213598394.16944.85.camel@twins>	 <20080616155630.78A9.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1213599882.16944.90.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760722AbYFPHIz@vger.kernel.org>
In-Reply-To: <1213599882.16944.90.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Peter Zijlstra wrote:
> On Mon, 2008-06-16 at 15:59 +0900, KOSAKI Motohiro wrote:
>> Hi Peter,
>>
>>>> # mount -t cgroup -o task none /dev/cgroup
>>>> # mkdir /dev/cgroup/foo
>>>> # cd /dev/cgroup/foo
>>>> # ls 
>>>> notify_on_release  task.max_tasks  task.nr_tasks  tasks
>>>> # echo 100 > task.max_tasks
>>>> # echo $$ > tasks
>>>> # fork_bomb 1000 &  <- try create 1000 process
>>>> # pgrep fork_bomb | wc -l
>>>> 98
>>> fwiw I think the name sucks!
>>> cgroups are about grouping tasks, so what's a task cgroup?
>> Sorry, my english skill is very low.
>> I hope restrict number of tasks.
>>
>> Do you have any name idea?
> 
> Sadly I suck at naming too ;-(
> 
> perhaps task_limit controller, or nr_tasks controller.
> 
> We should preferably pick one that transfers to most other rlimit like
> controls.
> 

We have memrlimit in -mm currently, which controls address space.
