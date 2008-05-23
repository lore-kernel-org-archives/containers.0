From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Date: Fri, 23 May 2008 14:23:05 +0900
Message-ID: <20080523142305.99c1972b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com>
	<4836411B.2030601@linux.vnet.ibm.com>
	<20080523131812.84F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<48364D38.7000304@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48364D38.7000304-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 23 May 2008 10:21:04 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> KOSAKI Motohiro wrote:
> >> One option is to limit the virtual address space usage of the cgroup to ensure
> >> that swap usage of a cgroup will *not* exceed the specified limit. Along with a
> >> good swap controller, it should provide good control over the cgroup's memory usage.
> > 
> > unfortunately, it doesn't works in real world.
> > IMHO you said as old good age.
> > 
> > because, Some JavaVM consume crazy large virtual address space.
> > it often consume >10x than phycal memory consumption.
> > 
> 
> Have you seen any real world example of this? 
I have no objection to that virual-address-space limitation can work well on
well-controlled-system. But there are more complicated systems in chaos.

One example I know was that a team for the system tried to count all vm space
for setting vm.overcommit_memory to be proper value. The just found they can't
do it on a server with tens of applications after a month.

One of difficult problem is that a system administrator can't assume the total 
size of virtual address space of proprietary applications/library. 
An application designer can estimate "the virutal address usage of an application
is between XXM to XXXXM. but admin can't esitmate the total.

In above case, the most problematic user of virual adddress space was pthreads.
Default stack size of pthreads on ia64 was 10M bytes (--; And almost all application
doesn't answer how small they can set its stack size to. It's crazy to set this value
per applications.  Then, "stack" of 2000 threads requires 20G bytes of virtual
address space on 12G system ;) They failed to use overcommit.

Thanks,
-Kame
