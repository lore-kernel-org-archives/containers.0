From: "Mukesh G" <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Devel] Re: Write Error: No space left on device
Date: Tue, 28 Oct 2008 12:58:16 +0530
Message-ID: <c7704c490810280028y74bb9c55pd9d6af844571fcd6@mail.gmail.com>
References: <c7704c490809050541v2df520f9ja9edc4582ee1199f@mail.gmail.com>
	<20080905080008.bf9748ab.pj@sgi.com>
	<c7704c490809150455r3376db54g8d37aba6670500a9@mail.gmail.com>
	<6599ad830809151726t4ff6082dsfda259dccd503415@mail.gmail.com>
	<c7704c490809170557o21330ceaoeca5193add14c6d4@mail.gmail.com>
	<6599ad830809171740t2cbb459dqc273f240b9877ed8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830809171740t2cbb459dqc273f240b9877ed8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I need your help in clarifying some doubts...

I have setup a container for cpu. Within the container with a cpu.shares of
1024 (default), which is made up of 2 cpu containers (C2048; cpu.shares
2048) and (C1024: cpu.shares 1024).

Enclosing a cpubusy script that keeps the cpu busy performing some dumb
processing. 2 instances of this script is executed on a dual core Intel x86
systems (PIDS: 21804, 21805)

#!/usr/bin/perl

$goal = 2181818;

while (TRUE) {
        for ($i=0; $i<=$goal; $i++) {
                $x = 0.000001;
                $y = sin($x);
                $y = $y + 0.00001;

        }

        next;
        $y = $y + 0.01;
}

By default, I have observed the running process becomes part of the tasks of
the main container system. The cpu's are 100% utilized, which is correct as
both the processes are in the same container (i.e. the parent cpu
container).

I now add a running cpubusy script process (PID: 21804) to the C2048
container.

Behavior 1: I noticed that the cpu utilization is still 100%, even though I
was expecting a change in the cpu utilization as there is some enforced
isolation. Am I reading this right?

I now add the second cpubusy script process (PID: 21805) to the C1024
container

Behavior 2: I noticed that the cpu utilization still at 100%. This time I
was expecting a change in cpu utilization. Not sure where I am going wrong?

The cpubusy script is inherently single threaded so created 2 additional
cpubusy scripts to simulate more processes (PID: 21872, 21873). Now, I see
the utilization change.

PID 21804: 66%
PID 21805: 50%
PID 21872: 50%
PID 21873: 33%

Behavior 3: I was expecting PIDs 21872 and 21873 as they belong to the
parent cpu container to have higher cpu utilization. The results are
surpursing as shown above.

Now, I add the process with PID: 21872 to container system C1024 and process
with PID: 21873

PID 21804: 66%
PID 21873: 66%
PID 21805: 33%
PID 21873: 33%

Behavior 4: This is the expected behavior.

Thanks

Mukesh

On Thu, Sep 18, 2008 at 6:10 AM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Wed, Sep 17, 2008 at 5:57 AM, Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > a)Definition of cpu.shares?
> >    the default value is 1024. What is the max?
>
> See Documentation/scheduler/sched-design-CFS.txt
>
> > b) What is the relation between cpuset.cpu* values and cpu cgroup?
>
> None.
>
> > c) What is the relation between cpuset.mem* values and memory cgroup?
>
> None.
>
> Paul
>
