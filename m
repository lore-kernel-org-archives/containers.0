From: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Make core_pattern support namespace
Date: Tue, 16 Feb 2016 15:26:09 +0100
Message-ID: <20160216142608.GA16757__33709.4068447643$1455632831$gmane$org@mguzik>
References: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ce9a21e42a846150a2a482278f5b5a5e0ea27839.1454588184.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Tue, Feb 16, 2016 at 07:33:39PM +0800, Zhao Lei wrote:
> Currently, each container shared one copy of coredump setting
> with the host system, if host system changed the setting, each
> running containers will be affected.
> 
> Moreover, it is not easy to let each container keeping their own
> coredump setting.
> 
> We can use some workaround as pipe program to make the second
> requirement possible, but it is not simple, and both host and
> container are limited to set to fixed pipe program.
> In one word, for host running contailer, we can't change core_pattern
> anymore.
> To make the problem more hard, if a host running more than one
> container product, each product will try to snatch the global
> coredump setting to fit their own requirement.
> 
> For container based on namespace design, it is good to allow
> each container keeping their own coredump setting.
> 
> It will bring us following benefit:
> 1: Each container can change their own coredump setting
>    based on operation on /proc/sys/kernel/core_pattern
> 2: Coredump setting changed in host will not affect
>    running containers.
> 3: Support both case of "putting coredump in guest" and
>    "putting curedump in host".
> 
> Each namespace-based software(lxc, docker, ..) can use this function
> to custom their dump setting.
> 
> And this function makes each continer working as separate system,
> it fit for design goal of namespace.
> 

Sorry if this is a false alarm, I don't have easy means to test it, but
is not this an immediate privilege escalation?

In particular, if the new pattern was to include a pipe, would not it
cause the kernel to run whatever the namespace put in there, but on the
"host"?

The feature definitely looks useful, but this is another privileged
operation which is now made available to unprivileged users. This poses
some questions:
- should the namespace be allowed to set anything it wants, including
  pipes? I would argue the latter should be disallowed for simplicity
- now that the pattern can change at any time by namespace root, it
  becomes fishy to parse it for filename generation without any
  protection against concurrent modification
- how do you ensure that namespaces which did not explicitely set their
  pattern still get updates from the host?

That said, I suggest adding an allocated buffer to hold it or be NULL
otherwise. If the pointer is NULL, the "host" pattern is used.

For dumping purposes the code could just kmalloc, rcu_read_lock, memcpy
and be done with it. Or, if it is acceptable given the size, just have a
buffer on the stack.

Finally, the code setting it could simply xchg the pointer to avoid
locks if there is no good lock to be taken here, and then kfree_rcu the
old buffer.

Just my $0,03.

-- 
Mateusz Guzik
