From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 3/3] Make core_pattern support namespace
Date: Wed, 23 Mar 2016 14:54:48 -0500
Message-ID: <87fuvhm0l3.fsf@x220.int.ebiederm.org>
References: <cover.1458305141.git.zhaolei@cn.fujitsu.com>
	<77053bb2bdd21489e09b6ef362044d283e1ba12b.1458305141.git.zhaolei@cn.fujitsu.com>
	<87twk0tlok.fsf@x220.int.ebiederm.org>
	<00fa01d18341$986e1880$c94a4980$@cn.fujitsu.com>
	<87shzkqmc8.fsf@x220.int.ebiederm.org>
	<00fb01d18359$b99df580$2cd9e080$@cn.fujitsu.com>
	<878u1bo772.fsf@x220.int.ebiederm.org>
	<010001d183db$7c0ae3e0$7420aba0$@cn.fujitsu.com>
	<87lh5am8wu.fsf@x220.int.ebiederm.org>
	<000001d184fb$424daea0$c6e90be0$@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <000001d184fb$424daea0$c6e90be0$@cn.fujitsu.com> (Zhao Lei's
	message of "Wed, 23 Mar 2016 19:58:04 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> Hi, Eric
>
>> -----Original Message-----
>> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
>> Sent: Wednesday, March 23, 2016 6:43 AM
>> To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
>> 'Mateusz Guzik' <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>; 'Kamezawa Hiroyuki'
>> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>> Subject: Re: [PATCH v2 3/3] Make core_pattern support namespace
>> 
>> Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>> 
>> > Hi, Eric
>> >
>> >> -----Original Message-----
>> >> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
>> >> Sent: Tuesday, March 22, 2016 5:25 AM
>> >> To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> >> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org;
>> >> 'Mateusz Guzik' <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>; 'Kamezawa Hiroyuki'
>> >> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>> >> Subject: Re: [PATCH v2 3/3] Make core_pattern support namespace
>> >>
>> >> Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>> >>
>> >> > Hi, Eric
>> >> >
>> >> >> -----Original Message-----
>> >> >> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
>> >>
>> >> > Let me make a summarize:
>> >> > You think this way is not acceptable, because the pipe program is running
>> >> > in the panic-process's namespace context.
>> >>
>> >> Actually my view is that your patchset is not acceptable because it
>> >> is implemented in a way that is not backwards compatible (AKA it can
>> >> break existing configurations that remain unchanged) and your
>> >> implementation does not appear in the least safe from malicious users.
>> >>
>> >> There is also a problem that your patchset is simply buggy for what it
>> >> tries to implement, as using pid_ns_for_children and the multiple kbuild
>> >> robot emails testifies.
>> >>
>> >> > And in my view, a pipe program in the host's top level namespace is also
>> >> > a problem.
>> >> >
>> >> > Let us think a container, to make it act as a real machine, when a program
>> >> > panic, linux kernel should dump it into the container's filesystem.
>> >> >
>> >> > For the kernel, to keep the current way of forking pipe program by kthread,
>> >> > just let the pipe thread running in the container's namespace, instead the
>> >> host,
>> >> > may solve the problem in current kernel.
>> >> >
>> >> > What is your opinion?
>> >> >
>> >> > Btw, this patch is trying to solve the problem descripted in thread named:
>> >> > "piping core dump to a program escapes container" in
>> >> >
>> >>
>> http://lists.linuxfoundation.org/pipermail/containers/2015-December/036476.
>> >> html
>> >> > Maybe using a userspace tool can make container dump to anywhere,
>> >> > but for kernel ifself, it is better to solve above problem if we can.
>> >>
>> >> I think it would be great to find a way to run a core dump helper and
>> >> otherwise allow setting the core dump pattern in a container in a way
>> >> that is safe from malicious users and does not break existing setups.
>> >>
>> > So, there is following problem:
>> > 1: safe from malicious users
>> >   We can try to find a way to fork process which have no relationship
>> >   with the panic process.
>> > 2: Bug in patch
>> >   It can be fixed, but I'd rather get a conclusion of this discussion
>> >   before fix.
>> > 3: Backwards compatible
>> >   It maybe the biggest problem in discussion, this patch is used to let
>> >   container dump files into container, it is different with current action.
>> >   Before patch:
>> >     File type dump_pattern: dump to container
>> >     Pipe type dump_pattern: dump to host
>> >   After patch:
>> >     File type dump_pattern: dump to container
>> >     Pipe type dump_pattern: dump to container
>> >   The second design seems better but not compatible with current kernel,
>> >   but this patch can not fix to keep compatible because it is the patch's
>> >   function.
>> >   Maybe we can make some workagound, as:
>> >   a. Add a kernel config to let the old style as default.
>> >   b. keep old style, and add "||" for core_pattern, as
>> >     echo "|| /root/container_dumper" >/proc/sys/kernel/core_pattern
>> >     to dump to container.
>> >
>> >   What is your opinion about it?
>> 
>
> Thanks for detailed answer.
>
>> There are two parts to backwards compatibility.
>> 
>> 1) How should core patterns that are set outside of any container be
>>    treated?
>> 
>>    The patchset under discussion imported core patterns set outside of
>>    containers into containers completely trivially changing their
>>    behavior and breaking backwards compatibility.  That is just not
>>    acceptable.
>> 
> Before this patch, setting pattern outside container will change setting
> in container.
> And after this patch, host and container are separated, they have respective
> setting, and no relationship except the container will copy host's setting
> in create.
>
> If we don't think compatibility, it may be a good idea, the container is only
> allowed to change the core_pattern by itself.
> It is strange that the core_pattern in container was changed but user/process
> in container do nothing.
>
> But just as you said, it have compatibility problem, someone maybe using
> this feature to modify core_pattern in container in host.
>
> To keep the compatibility and allow custom core_pattern in continer,
> maybe we can:
> 1: If no process setting core_pattern in container, the container's
>   core_pattern keep same copy with host.
>   And if core_pattern in host changed this time, the container's pattern
>   changed with host.
> 2: If core_pattern in container changed by some one/process in container,
>   it is separated with host, and modification in host will not affect container.
>
> What is your opinion about it?

That sounds correct.  Use the core_pattern for the container if it
exists otherwise use a core_pattern for an outer container/host.

>> 2) How should core patterns inside of containers be treated?
>> 
>>    There are corner cases that I am not thinking of that will cause
>>    regressions but I think we can reasonably assume that core patterns
>>    are not set inside of containers today.  Assuming that is true,
>>    then setting a core pattern inside of a container is the only thing
>>    that the kernel needs to detect to handle working inside of a
>>    container.
>> 
>>    The practical question I see for this case is which parent process
>>    needs to be used for your core dump helper, and which set of
>>    namespaces that parent helper has.
>> 
>>    I will also remind people thinking about these issues that containers
>>    can be run recursisvely.
>> 
> Got it.
> I'll try to find a way.

Eric
