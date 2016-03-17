From: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [PATCH 0/2] Make core_pattern support namespace
Date: Thu, 17 Mar 2016 10:22:24 +0800
Message-ID: <00a101d17ff3$d81859b0$88490d10$@cn.fujitsu.com>
References: <cover.1458119582.git.zhaolei@cn.fujitsu.com>
	<56EA00FC.3030800@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56EA00FC.3030800-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
To: 'Kamezawa Hiroyuki' <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 'Mateusz Guzik' <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Kamezawa-san

> From: Kamezawa Hiroyuki [mailto:kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org]
> Sent: Thursday, March 17, 2016 8:58 AM
> To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Mateusz
> Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Subject: Re: [PATCH 0/2] Make core_pattern support namespace
> 
> On 2016/03/16 18:23, Zhao Lei wrote:
> > We discussed patch titled:
> >   [PATCH] Make core_pattern support namespace
> > before.
> >
> > Above patch can solve half problem of custom core_dump pattern
> > in container, but there are also another problem that limit
> > custom core_pattern in container, it is the pipe-type core_pattern
> > will write core dump into host's filesystem.
> > (See discussion of that patch for detail)
> >
> > Now we can solve the second problem by [PATCH 1/2], I send
> > the origional patch with it.
> >
> 
> Let me know your design...
> 
> This patch does using fork+execve() rather than calling UMH in pipe-coredump
> pass.
> And coredump-pipe process is run as a child of get-dumped process.
> Right ?
> 
Yes.
It is why we can search pipe-coredump in container's filesystem,
and let it write coredump into container's filesystem.

> Doesn't this break existing solution actually used in distro ?
> 
It changed core_pattern of pipe type in container.

In detail, for solution:
1: Using file type core_pattern: No changed
2: No container coredump support: No changed
3: Support container corecump using pipe: the pipe progeam should be placed in container instead of host
  The container manager should modify setting to use new interface,
  Or simply keep old habit by binding dump program and dump dir into container.

> BTW, it's first time for me to see that _do_fork() is called outside from fork.c.
> Isn't it better to add a new func in fork.c if we really need this ?
> 
Actually we already have do_fork() as a wapper of _do_fork.
But it is used for compatibility with special platform and not always exist.
Maybe we can use kernel_thread() instead.

Thanks
Zhaolei
