From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH] Make core_pattern support namespace
Date: Thu, 18 Feb 2016 19:13:49 +0800
Message-ID: <009501d16a3d$713c46a0$53b4d3e0$@cn.fujitsu.com>
References: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei@cn.fujitsu.com>
	<20160216142608.GA16757@mguzik>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160216142608.GA16757@mguzik>
Content-Language: zh-cn
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Mateusz Guzik' <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Mateusz Guzik

Thanks for your detailed comment and suggestion on this patch.

> -----Original Message-----
> From: Mateusz Guzik [mailto:mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
> Sent: Tuesday, February 16, 2016 10:26 PM
> To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Subject: Re: [PATCH] Make core_pattern support namespace
> 
> On Tue, Feb 16, 2016 at 07:33:39PM +0800, Zhao Lei wrote:
> > Currently, each container shared one copy of coredump setting
> > with the host system, if host system changed the setting, each
> > running containers will be affected.
> >
> > Moreover, it is not easy to let each container keeping their own
> > coredump setting.
> >
> > We can use some workaround as pipe program to make the second
> > requirement possible, but it is not simple, and both host and
> > container are limited to set to fixed pipe program.
> > In one word, for host running contailer, we can't change core_pattern
> > anymore.
> > To make the problem more hard, if a host running more than one
> > container product, each product will try to snatch the global
> > coredump setting to fit their own requirement.
> >
> > For container based on namespace design, it is good to allow
> > each container keeping their own coredump setting.
> >
> > It will bring us following benefit:
> > 1: Each container can change their own coredump setting
> >    based on operation on /proc/sys/kernel/core_pattern
> > 2: Coredump setting changed in host will not affect
> >    running containers.
> > 3: Support both case of "putting coredump in guest" and
> >    "putting curedump in host".
> >
> > Each namespace-based software(lxc, docker, ..) can use this function
> > to custom their dump setting.
> >
> > And this function makes each continer working as separate system,
> > it fit for design goal of namespace.
> >
> 
> Sorry if this is a false alarm, I don't have easy means to test it, but
> is not this an immediate privilege escalation?
> 
> In particular, if the new pattern was to include a pipe, would not it
> cause the kernel to run whatever the namespace put in there, but on the
> "host"?
> 
In my mind, if user don't run vm in with privilege request,
the container manager can do following processing:
1: User set custom core_pattern in starting container, as:
   # lxc-start --core-pattern='xxx' -n vm01
   or
   # docker run --core-pattern='xxx' my_image
   or
   set CORE_PATTERN in vm's config file
2: Container manager(lxc or docker) mount /proc as rw in init period,
   and set core_pattern.
3: Container manager remount /proc as ro, and give vm to user.
User/program in vm can not change core_pattern setting, just as lxc
and docker's current default behavor.

If user run vm with privilege request, it will be a problem.
User/process in vm can change core-pattern setting, if change to a file,
it is not a problem, because it is a file in vm's filesystem.
But if changed to a pipe, it is a problem in current kernel design,
the pipe program is in host's filesystem, it means the vm can change host.

In short:
 Run vm in non-privilege | do anything                 | no problem
 Run vm in privilege     | change core_pattern to file | no problem
 Run vm in privilege     | change core_pattern to pipe | IS problem

As a solution, maybe we can modify kernel to search the pipe program
in vm's filesystem, and the pipe problem runs in vm's fs context,
so a vm can only put dump file in its private filesystem, except vm
manager link the dir into host.

Another solution is to only allow vm change core_pattern to file(avoid pipe),
but is looks strange, the vm should have same core_dump setting function
with normal system.

> The feature definitely looks useful, but this is another privileged
> operation which is now made available to unprivileged users. This poses
> some questions:
> - should the namespace be allowed to set anything it wants, including
>   pipes? I would argue the latter should be disallowed for simplicity
Yes, current patch does allow, it can be fixed in above way.

> - now that the pattern can change at any time by namespace root, it
>   becomes fishy to parse it for filename generation without any
>   protection against concurrent modification
Before this patch, kernel can works corrent, so I think kernel already
have lock to avoid changing and reading the cure_pattern buffer in
same time.
This patch only modify the buffer place, so the existence lock will
still can work, I'll confirm it in source.

> - how do you ensure that namespaces which did not explicitely set their
>   pattern still get updates from the host?
> 
> That said, I suggest adding an allocated buffer to hold it or be NULL
> otherwise. If the pointer is NULL, the "host" pattern is used.
> 
> For dumping purposes the code could just kmalloc, rcu_read_lock, memcpy
> and be done with it. Or, if it is acceptable given the size, just have a
> buffer on the stack.
> 
> Finally, the code setting it could simply xchg the pointer to avoid
> locks if there is no good lock to be taken here, and then kfree_rcu the
> old buffer.
> 
Actually I considered about this way in doing patch, as:
HOST        core_pattern=foo
+- VM1      core_pattern=NULL
   +- VM1_1 core_pattern=NULL
VM1 and VM1_1 use nearext core_pattern setting in tree(foo).

And if VM1_1 changed core pattern to bar:
HOST        core_pattern=foo
+- VM1      core_pattern=NULL
   +- VM1_1 core_pattern=bar
VM1 use foo and VM1_1 use bar.

It means vm can always set core_pattern buffer pointer to NULL in creating,
until someone changes it.
But I finally selected to clone core_pattern in creating vm, because if we
see a vm as a independent system, its core_pattern should only changed by
process running in it, and after a vm got created, the host will not able
to change vm's internal setting, except login/run_command in vm's context.

Thanks
Zhaolei

> Just my $0,03.
> 
> --
> Mateusz Guzik
