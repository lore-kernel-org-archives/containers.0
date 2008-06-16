From: Midori Sugaya <doly-uo9agqpHHEbPUJYwFPjUlCGn5s73+xxf@public.gmane.org>
Subject: Re: mini-summit agenda
Date: Mon, 16 Jun 2008 10:49:34 +0900
Message-ID: <20080616054702.F50F.DOLY@dcl.info.waseda.ac.jp>
References: <20080615214743.845F.DOLY@dcl.info.waseda.ac.jp>
	<20080615155044.GA4427@linux.vnet.ibm.com>
Reply-To: doly-uo9agqpHHEbPUJYwFPjUlCGn5s73+xxf@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080615155044.GA4427-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Dhaval,
 
> There already is a CPU and a memory resource management based on top of
> cgroups in mainline. How is your implementation different from the one
> already in mainline?

Basic idea is similar as the cpusets that it will set caps for processes.
In our system, user set the period and maximum execution time for the
group of processes through the cgroup filesystem.

The different is that our implementation uses hrtimer (kernel timer) 
functions to measure the time of execution for each process. It makes
our system independent from the scheduler. 
I think the point is different from the mainline cpusets implementation.
Memory management is a simple mechanism to hook the pagefault function
to track the quantum of using pages for group of processes. 
 
Our implementation is focus on the embedded system which is the demand 
to control the task with absolute period and execution time and low overhead.
 
> > I hear cgroup meetnig will be held in Otawa Linux kernel symposium, and
> > I would like to attend this meeting for sharing latest informations and
> > future roadmap of cgroups.
> > Could I attend the meeting?
> > 
> 
> Sure, it is open for all.

Thanks. I'm looking forward to joinig you.

Midori
