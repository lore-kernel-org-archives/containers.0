From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Sun, 23 Aug 2009 18:18:17 +0200
Message-ID: <4A916BC9.8040905@free.fr>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Krzysztof Taraszka wrote:
> Hello,
> 
> I am running lxc on my debian unstable sandbox and I have a few question
> about memory managament inside linux containers based on lxc project.
> 
> I have got linux kernel 2.6.30.5 with enabled :
> 
> +Resource counter
> ++ Memory Resource Controller for Control Groups
>  +++ Memory Resource Controller Swap Extension(EXPERIMENTAL)
> 
> lxc-checkconfig pass all checks.
> 
> I read about cgroups memory managament (Documentation/cgroups/memory.txt)
> and I tried to pass those value to my debian sandbox.
> 
> And...
> 'free -m' and 'top/htop' still show all available memory inside container
> (also If I set 32M for lxc.cgroup.memory.limit_in_bytes and
> lxc.cgroup.memory.usage_in_bytes; and 64M for
> lxc.cgroup.memory.memsw.usage_in_bytes and
> lxc.cgroup.memory.memsw.limit_in_bytes free and top show all resources).
> 
> What I did wrong? Does the container always show all available memory
> resources  without cgroup limitations?

At the first glance I would say the configuration is correct.
But AFAIR, the memory cgroup is not isolated, if you specify 32MB you 
will see all the memory available on the system either if you are not 
allowed to use more than 32MB. If you create a program which allocates 
64MB within a container configured with 32MB, and you "touch" the pages 
(may be that can be done with one mmap call with the MAP_POPULATE 
option), you should see the application swapping and the 
"memory.failcnt" increasing.

IMHO, showing all the memory available for the system instead of showing 
the allowed memory with the cgroup is weird but maybe there is a good 
reason to do that.

   -- Daniel

ps: cc'ed the containers@
