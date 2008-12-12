From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: container userspace tools
Date: Fri, 12 Dec 2008 19:55:29 +0530
Message-ID: <20081212142529.GD4365@balbir.in.ibm.com>
References: <48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0812112333k6c1474f3hb67e963b39a0d0d6@mail.gmail.com>
	<20081212081238.GA4365@balbir.in.ibm.com>
	<8f34198c0812120106k390a1097ub31905cd2bc44676@mail.gmail.com>
	<20081212091829.GB4365@balbir.in.ibm.com>
	<8f34198c0812120202t39582a27k47c98b88246f18ce@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8f34198c0812120202t39582a27k47c98b88246f18ce-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

* Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2008-12-12 18:02:22]:

> >
> > OK, so this is not an lxc kernel, but a mainline kernel.
> >
> 
> So, what is the lxc kernel you meat? Is it different from the
> 2.6.27-rc8. I use that version  recommended by Daniel.
> 
> >>
> >> > 1. Can you see the memory.usage_in_bytes corresponding to the control
> >> > group where you run the container
> >>
> >> How can I know the number correspond to the control group?
> >
> > From outside the container, figure out the process id of init and then
> > do a cat /proc/<pid>/cgroup. Then go to that directory and cat
> > memory.usage_in_bytes, memory.stat and memory.limit_in_bytes to verify
> > the setup
> >
> 
> OK, I have done the checking, but I don't understand what is meaning of
> "corresponding". The content is shown as follows:
> 
> $ cat /proc/4506/cgroup
> 255:freezer,devices,memory,cpuacct,cpu,ns,debug,cpuset:/
> $ cat memory.usage_in_bytes
> 223932416

OK, so memory.usage_in_bytes is 223932416 for the root cgroup. You
process 4506, which is (I assume) a container process is running in
"/" or the root cgroup. By default root cgroups are unlimited. You can
verify by reading memory.limit_in_bytes

> 
> 
> >>
> >> > 2. Check tasks file to see that the container tasks are indeed in the
> >> > container.
> >> >
> >>
> >> My program forks a child and its child (grandson of previous process) call the
> >> the /bin/bash to open a shell. I just can find the parent process is
> >> in container
> >> tasks file, but its child and grandson process are not.
> >>
> >
> > Hmmm.. but the child and grandson are alive right?
> yes... I can see them by a container-outside bash running with ps
> 
> > Do a cat
> > /proc/<pid>/cgroup on them to see where they went or where they are.
> >
> 
> They are all there, similar with pid=4506.
> 
> $ cat /proc/4506/cgroup
> 255:freezer,devices,memory,cpuacct,cpu,ns,debug,cpuset:/
> $ cat /proc/4507/cgroup
> 255:freezer,devices,memory,cpuacct,cpu,ns,debug,cpuset:/4507
> $ cat /proc/4508/cgroup
> 255:freezer,devices,memory,cpuacct,cpu,ns,debug,cpuset:/4506
>

Are there three containers on the system

Can you send me the output of <cgroup mount point>/4507/memory.* and
4506/memory.*. cgroup mount point can be obtained from /proc/mounts.
 

-- 
	Balbir
