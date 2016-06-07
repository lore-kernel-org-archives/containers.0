From: Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 3/3] Write dump into container's filesystem for
	pipe_type core_pattern
Date: Tue, 7 Jun 2016 21:09:42 +0200
Message-ID: <20160607190941.d4hfqehvwxylon4l@mguzik>
References: <cover.1465293010.git.zhaolei@cn.fujitsu.com>
	<9d61a9a95ca4c323adc182abf32714b46e963405.1465293010.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9d61a9a95ca4c323adc182abf32714b46e963405.1465293010.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 07, 2016 at 07:29:37PM +0800, Zhao Lei wrote:
> In current system, when we set core_pattern to a pipe, both pipe program
> and program's output are in host's filesystem.
> But when we set core_pattern to a file, the container will write dump
> into container's filesystem.
> 
> For example, when we set following core_pattern:
>  # echo "|/my_dump_pipe %s %c %p %u %g %t e" >/proc/sys/kernel/core_pattern
> and trigger a segment fault in a container, my_dump_pipe is searched from
> host's filesystem, and it will write coredump into host's filesystem too.
> 
> In a privileged container, user can destroy host system by following
> command:
>  # # In a container
>  # echo "|/bin/dd of=/boot/vmlinuz" >/proc/sys/kernel/core_pattern
>  # make_dump
> 
> Actually, all operation in a container should not change host's
> environment, the container should use core_pattern as its private setting.
> In detail, in core dump action:
> 1: Search pipe program in container's fs namespace.
> 2: Run pipe program in container's fs namespace to write coredump to it.
> 
> This patch fixed above problem by running pipe program with container's
> fs_root.
> 

This does not look sufficient, but I can't easily verify.

For instance, is the spawned process able to attach itself with ptrace
to processes outside of the original container? Even if not, can it
mount procfs and use /proc/pid/root of processes outside of said
container?

The spawned process should be subject to all limitations imposed on the
container (which may mean it just must be in the container).

-- 
Mateusz Guzik
