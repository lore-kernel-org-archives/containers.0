From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: No limitation in physical memory in cgroups
Date: Wed, 20 May 2009 15:05:44 +0800
Message-ID: <4A13ABC8.2000907@cn.fujitsu.com>
References: <d95d44a20905192252t6cce5169y730a37184075beb9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d95d44a20905192252t6cce5169y730a37184075beb9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

anqin wrote:
> Hi all,
> 
> I would like to bind given physical memory to specific task group,
> however it does not take effect in my experiments. Are there
> something wrong in my experiments.
> 
> My experiment is done under the kernel 2.6.29.3 and I constructed
> my task group by following commands:
> 
> a) In shell #1, prepare a bash :
> 
> # bash
> # echo $$
> 2253
> 

The pid of shell #1 is 2253.

> b) In shell #2, prepare the memory control via cgroupfs:
> 
> # mount -t cgroup cgroup /mnt/mycgrp
> # cd /mn/mycgrp
> # mkdir mycontainer
> # echo 0 > mycontainer/cpuset.mems
> # echo 0-1 > mycontainer/cpuset.cpus
> # echo 2252 > mycontainer/tasks
> 

but this is 2252 !!

> # cat mycontainer/memory.usage_in_bytes
> 2875392
> # echo 3000000 > mycontainer/memory.max_usage_in_bytes
> # cat mycontainer/memory.max_usage_in_bytes
> 3002368
> 
> 
> c) In Shell #1, run a memory consumer (in which, malloc() is called
> to allocate memory and not free until program is existed) to allocate
> 500M memory:
> 
> # /tmp/memoy_consumer_program  500
> 
> In Shell #2, the used memory ascends from start point 2875392 when
> program begins (from number presented in memory.usage_in_bytes),
> but it return to start point when it touches the maximal boundary.
> 
> On the other hand, I also run the top to watch the memory hold by
> memoy_consumer_program. In top, the memory (both virtual and rss
> memory ) is always growing without any limitation.
> 
> Is this phenomenon the correct behaviors of memory cgroups?
> 
> 
> Best Regards,
