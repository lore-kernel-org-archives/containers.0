From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 3/3] Make core_pattern support namespace
Date: Mon, 21 Mar 2016 16:24:33 -0500
Message-ID: <878u1bo772.fsf@x220.int.ebiederm.org>
References: <cover.1458305141.git.zhaolei@cn.fujitsu.com>
	<77053bb2bdd21489e09b6ef362044d283e1ba12b.1458305141.git.zhaolei@cn.fujitsu.com>
	<87twk0tlok.fsf@x220.int.ebiederm.org>
	<00fa01d18341$986e1880$c94a4980$@cn.fujitsu.com>
	<87shzkqmc8.fsf@x220.int.ebiederm.org>
	<00fb01d18359$b99df580$2cd9e080$@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <00fb01d18359$b99df580$2cd9e080$@cn.fujitsu.com> (Zhao Lei's
	message of "Mon, 21 Mar 2016 18:09:15 +0800")
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

> Let me make a summarize:
> You think this way is not acceptable, because the pipe program is running
> in the panic-process's namespace context.

Actually my view is that your patchset is not acceptable because it
is implemented in a way that is not backwards compatible (AKA it can
break existing configurations that remain unchanged) and your
implementation does not appear in the least safe from malicious users.

There is also a problem that your patchset is simply buggy for what it
tries to implement, as using pid_ns_for_children and the multiple kbuild
robot emails testifies.

> And in my view, a pipe program in the host's top level namespace is also
> a problem.
>
> Let us think a container, to make it act as a real machine, when a program
> panic, linux kernel should dump it into the container's filesystem.
>
> For the kernel, to keep the current way of forking pipe program by kthread,
> just let the pipe thread running in the container's namespace, instead the host,
> may solve the problem in current kernel.
>
> What is your opinion?
>
> Btw, this patch is trying to solve the problem descripted in thread named:
> "piping core dump to a program escapes container" in
> http://lists.linuxfoundation.org/pipermail/containers/2015-December/036476.html
> Maybe using a userspace tool can make container dump to anywhere,
> but for kernel ifself, it is better to solve above problem if we can.

I think it would be great to find a way to run a core dump helper and
otherwise allow setting the core dump pattern in a container in a way
that is safe from malicious users and does not break existing setups.

Eric
