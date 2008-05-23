From: David Singleton <David.Singleton-FCV4sgi5zeUQrrorzV6ljw@public.gmane.org>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Date: Fri, 23 May 2008 15:29:31 +1000
Message-ID: <4836563B.4060603@anu.edu.au>
References: <20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com>
	<4836411B.2030601@linux.vnet.ibm.com>
	<20080523131812.84F1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<48364D38.7000304@linux.vnet.ibm.com>
Reply-To: David.Singleton-FCV4sgi5zeUQrrorzV6ljw@public.gmane.org
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
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Linux MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> KOSAKI Motohiro wrote:
>>> One option is to limit the virtual address space usage of the cgroup to ensure
>>> that swap usage of a cgroup will *not* exceed the specified limit. Along with a
>>> good swap controller, it should provide good control over the cgroup's memory usage.
>> unfortunately, it doesn't works in real world.
>> IMHO you said as old good age.
>>
>> because, Some JavaVM consume crazy large virtual address space.
>> it often consume >10x than phycal memory consumption.
>>
> 
> Have you seen any real world example of this? 

At the unsophisticated end, there are lots of (Fortran) HPC applications
with very large static array declarations but only "use" a small fraction
of that.  Those users know they only need a small fraction and are happy
to volunteer small physical memory limits that we (admins/queuing
systems) can apply.

At the sophisticated end, the use of numerous large memory maps in
parallel HPC applications to gain visibility into other processes is
growing.  We have processes with VSZ > 400GB just because they have
4GB maps into 127 other processes.  Their physical page use is of
the order 2GB.

Imposing virtual address space limits on these applications is
meaningless.


The overcommit feature of Linux.
> We usually by default limit the overcommit to 1.5 times total memory (IIRC).
> Yes, one can override that value, you get the same flexibility with the virtual
> address space controller.
> 
> I thought java was particular about it with it's heap management options and policy.
> 
>> yes, that behaviour is crazy. but it is used widely.
>> thus, We shouldn't assume virtual address space limitation.
> 
> It's useful in many cases to limit the virtual address space - to allow
> applications to deal with memory failure, rather than
> 
> 1. OOM the application later
> 2. Allow uncontrolled swapping (swap controller would help here)
> 

David
