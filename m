From: Tomasz Buchert <Tomasz.Buchert-MZpvjPyXg2s@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: Freezing and task move race fix
Date: Wed, 11 Aug 2010 09:30:09 +0200
Message-ID: <4C625181.4060606__29995.9996519194$1281511866$gmane$org@inria.fr>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
	<20100811011033.GF2927@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100811011033.GF2927-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Matt Helsley a =E9crit :
> On Tue, Aug 10, 2010 at 09:53:21PM +0200, Tomasz Buchert wrote:
>> Writing 'FROZEN' to freezer.state file does not
>> forbid the task to be moved away from its cgroup
>> (for a very short time). Nevertheless the moved task
>> can become frozen OUTSIDE its cgroup which puts
>> discussed task in a permanent 'D' state.
> =

> SUMMARY (for supporting info see the "DETAILS" heading below)
> =

> I can't reproduce this.
> =

> My preliminary conclusion is that your testcase doesn't really reproduce
> what you described. Instead, your testcase prints an incorrect message wh=
ich
> could easily lead the person running it to the wrong conclusion.
> =

> DETAILS
> =

> I tried it with and without the cpuset portions of the testcase on a dual
> core bare metal system with a 2.6.31-derived distro kernel. Since it
> *should* be obeying the cpuset portions of the testcase I don't think the
> fact that it's dual-core should make a difference.
> =

> I also tried with a 2.6.34-rc5 kernel in a single-cpu kvm on a different
> distro (but on the same physical hardware). I also tried it with and with=
out
> the sleep(1) in the child's for(;;) loop in case the cpu load somehow ena=
bled
> me to trigger the race.
> =

> I used the following bash snippet to run the testcase variations and did =
not
> observe any tasks in the D state:
> =

> mount -t cgroup -o freezer,cpuset none /cg
> while /bin/true ; do
> 	./bug /cg
> 	ps -C bug -o state=3D | grep D && break
> done
> =

> If there is a race then I should be able to run that ps line anytime afte=
rwards
> to see the stuck task.
> =

> Note that the test message:
> =

> 	printf("Succesfully moved frozen task!\n");
> =

> is bogus. In fact there is no guarantee the task or cgroup is frozen at t=
hat
> point in the testcase. This should be apparent from a careful reading of
> Documentation/cgroups/freezer-subsystem.txt, especially:
> =

> 	This is the basic mechanism which should do the right thing for user spa=
ce task
> 	in a simple scenario.
> =

> 	It's important to note that freezing can be incomplete. In that case we =
return
> 	EBUSY. This means that some tasks in the cgroup are busy doing something=
 that
> 	prevents us from completely freezing the cgroup at this time. After EBUS=
Y,
> 	the cgroup will remain partially frozen -- reflected by freezer.state re=
porting
> 	"FREEZING" when read. The state will remain "FREEZING" until one of these
> 	things happens:
> =

> 		1) Userspace cancels the freezing operation by writing "THAWED" to
> 			the freezer.state file
> 		2) Userspace retries the freezing operation by writing "FROZEN" to
> 			the freezer.state file (writing "FREEZING" is not legal
> 			and returns EINVAL)
> 		3) The tasks that blocked the cgroup from entering the "FROZEN"
> 			state disappear from the cgroup's set of tasks.
> =

> So simply writing FROZEN to freezer.state is necessary to initiate freezi=
ng
> but insufficient to assert that the task and/or cgroup is frozen.
> That's why the FREEZING state exists. It's intentionally not specified wh=
en/why
> we can't immediately enter FROZEN. Thus userspace must read the freezer.s=
tate
> to determine if the current state matches the requested/expected state.
> =

> This is why I have the extra ps step in the script above -- to determine
> if the task is actually in D. I should also check that the cgroup it belo=
ngs
> to is THAWED. However while attempting to reproduce your report that hasn=
't
> been necessary -- none of the tasks have even entered the D state.
> =

> Which brings us to the final portion of this analysis: Why isn't anything
> entering the D state?
> =

> The behavior I have been able to reproduce and which is not a bug is
> moving the task immediately after writing FROZEN to freezer.state. We don=
't
> know the state of the task or cgroup at that time (in this testcase) so
> this is acceptable. I've even made a sequence of modifications to your
> testcase and run it after each modification to bring it successively more
> in line with correct use of the cgroup freezer. I still was unable to
> reproduce your report.
> =

> So I'm fairly confident there is no bug. I say "fairly" because there may
> be some aspect of your system that I am not reproducing. At this point it
> would be great if you could provide more details so I can more thoroughly
> attempt to recreate your conditions.
> =

> Cheers,
> 	-Matt Helsley
> =


Maybe this is a problem with different timings. I have a qemu minimal image
with two different kernels 2.6.35 - vanilla and patached. I don't use kvm
with qemu though. You can get it from here:
	http://pentium.hopto.org/~thinred/files/qemu.tar.bz2
in the package there is also minimal '.config' for current Linus's tree.
You run it with ./run-linux <bzImageOfTheKernel>. In /root you will have
'minimal' program which is my testcase. The small problem with this image i=
s that
ps segfaults but it's not a big problem. :)

I am also aware that:
	printf("Succesfully moved frozen task!\n");
does not show that task was moved. Only the message is just wrong. What I w=
anted to observe
is that the kernel actually ALLOWED to start the process of freezing.
When you run the testcase with 'strace' you'll see that 'write' returns a p=
ositive number
instead of -EBUSY. And that's the bug.

Anyway, I deduce from your later mail that you actually reproduced the prob=
lem.

Cheers,
Tomasz
