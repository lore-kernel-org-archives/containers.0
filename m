From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 6/7] bio-cgroup: Implement the bio-cgroup
Date: Fri, 08 Aug 2008 20:41:13 +0900 (JST)
Message-ID: <20080808.204113.39165145.ryov__6315.61880368299$1218195794$gmane$org@valinux.co.jp>
References: <489BF14D.6050009@oss.ntt.co.jp>
	<20080808.173045.112614776.ryov@valinux.co.jp>
	<489C150C.5040700@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <489C150C.5040700-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Yoshikawa-san,

> I wanted to test my own scheduler which uses bio tracking information.
> SO I tried your patch, especially, get_bio_cgroup_iocontext(), to get
> the io_context from bio.
>
> In my test, I made some threads with certain iopriorities run
> concurrently. To schedule these threads based on their iopriorities,
> I made BGROUP directories for each iopriorities.
> e.g. /cgroup/bio/be0 ... /cgroup/bio/be7
> Then, I tried to attach the processes to the appropriate groups.
> 
> But the processes stayed in the original group(id=0).

In the current implementation, when a process moves to an another cgroup:
  - Already allocated memory does not move to the cgroup, still remains.
  - Only allocated memory after move belongs to the cgroup.
This behavior follows the memory controller.

Memory does not move between cgroups since it is so heavy operation, 
but it would be worth under some sort of conditions.

Could you try to move a process between cgroups in the following way?

   # echo $$ > /cgroup/bio/be0
   # run_your_program
   # echo $$ > /cgroup/bio/be1
   # run_your_program
   ...

> I am sorry but I have to leave now and I cannot come here next week.
> --> I will take summer holidays.

Have a nice vacation!

Thanks,
Ryo Tsuruta
