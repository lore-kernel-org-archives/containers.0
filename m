From: "Mukesh G" <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Devel] Re: Write Error: No space left on device
Date: Tue, 28 Oct 2008 15:37:52 +0530
Message-ID: <c7704c490810280307s141a7a18vc708049e7f499c50@mail.gmail.com>
References: <c7704c490809050541v2df520f9ja9edc4582ee1199f@mail.gmail.com>
	<20080905080008.bf9748ab.pj@sgi.com>
	<c7704c490809150455r3376db54g8d37aba6670500a9@mail.gmail.com>
	<6599ad830809151726t4ff6082dsfda259dccd503415@mail.gmail.com>
	<c7704c490809170557o21330ceaoeca5193add14c6d4@mail.gmail.com>
	<6599ad830809171740t2cbb459dqc273f240b9877ed8@mail.gmail.com>
	<c7704c490810280028y74bb9c55pd9d6af844571fcd6@mail.gmail.com>
	<20081028083806.GB4097@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081028083806.GB4097-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
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
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Dhaval,
    Thanks for clarifying some doubts. Further to your mail and my
understanding, I can make some conclusions

1) Even though there is a hierarchical order for containers, the shares are
not allocated in terms of that order i.e. If the parent container has a
certain no of cpu.shares and more child containers. The parent and child
containers have the same priority.

2) For only 2 process running on a dual core system and If I have one
process assigned to C2048 container and another process assigned to C1024
container, I would expect the scheduler to allocate in the order of 2:1.
Behavior 2 indicates that allocation did not happen.

3) I ran the experiment having 2 instances of multi-threaded version of java
workload on the same system and noticed that 2:1 scenario did not repeat.
Hence, a multi threaded code does not benefit from this kind of a scheduler.

4) If you have more processes than the no of cores for the cpu shares to
work.

Thanks

Mukesh

On Tue, Oct 28, 2008 at 2:08 PM, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>wrote:

> On Tue, Oct 28, 2008 at 12:58:16PM +0530, Mukesh G wrote:
> > Hi,
> >
> > I need your help in clarifying some doubts...
> >
> > I have setup a container for cpu. Within the container with a cpu.shares
> of
> > 1024 (default), which is made up of 2 cpu containers (C2048; cpu.shares
> > 2048) and (C1024: cpu.shares 1024).
> >
> > Enclosing a cpubusy script that keeps the cpu busy performing some dumb
> > processing. 2 instances of this script is executed on a dual core Intel
> x86
> > systems (PIDS: 21804, 21805)
> >
> > #!/usr/bin/perl
> >
> > $goal = 2181818;
> >
> > while (TRUE) {
> >         for ($i=0; $i<=$goal; $i++) {
> >                 $x = 0.000001;
> >                 $y = sin($x);
> >                 $y = $y + 0.00001;
> >
> >         }
> >
> >         next;
> >         $y = $y + 0.01;
> > }
> >
> > By default, I have observed the running process becomes part of the tasks
> of
> > the main container system. The cpu's are 100% utilized, which is correct
> as
> > both the processes are in the same container (i.e. the parent cpu
> > container).
> >
> > I now add a running cpubusy script process (PID: 21804) to the C2048
> > container.
> >
> > Behavior 1: I noticed that the cpu utilization is still 100%, even though
> I
> > was expecting a change in the cpu utilization as there is some enforced
> > isolation. Am I reading this right?
> >
>
> Hi Mukesh,
>
> Not really. You would not see any change in CPU utlization. The group
> scheduler is a propotional scheduler, that is it divides the CPU
> bandwidth as per the propotion of the cpu shares. Now, you have only 1
> process running, so it will get all the bandwidth available.
>
> > I now add the second cpubusy script process (PID: 21805) to the C1024
> > container
> >
> > Behavior 2: I noticed that the cpu utilization still at 100%. This time I
> > was expecting a change in cpu utilization. Not sure where I am going
> wrong?
> >
>
> Right, I notice you are on a dual core machine. That means both the
> processes will be on different CPUs, and so you get to see the 100%
> utilization for both the processes. (since a process can utilize more
> than one CPU )
>
> > The cpubusy script is inherently single threaded so created 2 additional
> > cpubusy scripts to simulate more processes (PID: 21872, 21873). Now, I
> see
> > the utilization change.
> >
> > PID 21804: 66%
> > PID 21805: 50%
> > PID 21872: 50%
> > PID 21873: 33%
> >
> > Behavior 3: I was expecting PIDs 21872 and 21873 as they belong to the
> > parent cpu container to have higher cpu utilization. The results are
> > surpursing as shown above.
> >
>
> Not really. What happens is that the CPU bandwidth available to a
> control group is divided between the tasks and task groups as per their
> weight. Assuming that you were running just nice 0 tasks, I would expect
> C2048:C1024:PID21872:PID21873 to share CPU bandwidth in the ratio
> 2:1:1:1. Since there are 4 tasks, they would be split 2 on each core,
> with the division of bandwidth being as per their weights. (So ideally
> it should have been 80%, 40%, 40%, 40%, but is what you see).
>
> > Now, I add the process with PID: 21872 to container system C1024 and
> process
> > with PID: 21873
> >
> > PID 21804: 66%
> > PID 21873: 66%
> > PID 21805: 33%
> > PID 21873: 33%
> >
> > Behavior 4: This is the expected behavior.
> >
>
> Yes, absolutely true :).
>
> Hope that helped
>
> Thanks,
> --
> regards,
> Dhaval
>
