From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2] /proc/pid/status: show all sets of pid according to ns
Date: Thu, 29 May 2014 15:31:30 +0400
Message-ID: <53871A92.9000004@parallels.com>
References: <1401272683-1659-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5385DA19.2060008@parallels.com> <20140528182824.GA5057@cachalot>
	<53863889.9080509@parallels.com> <20140529055954.GA10354@cachalot>
	<5386F8EA.8050501@parallels.com> <20140529111236.GA14576@cachalot>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140529111236.GA14576@cachalot>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On 05/29/2014 03:12 PM, Vasily Kulikov wrote:
> On Thu, May 29, 2014 at 13:07 +0400, Pavel Emelyanov wrote:
>> On 05/29/2014 09:59 AM, Vasily Kulikov wrote:
>>> On Wed, May 28, 2014 at 23:27 +0400, Pavel Emelyanov wrote:
>>> ] We need a direct method of getting the pid inside containers.
>>> ] If some issues occurred inside container guest, host user
>>> ] could not know which process is in trouble just by guest pid:
>>> ] the users of container guest only knew the pid inside containers.
>>> ] This will bring obstacle for trouble shooting.
>>>
>>> A new syscall might complicate trouble shooting by admin.
>>
>> Pure syscall -- yes. What if we teach the ps and top utilities to show additional
>> info? I think that would help.
> 
> I like the idea with low level non-shell API which can be used by
> utility like ps (or implementation of a new tool to work with complex
> namespace hierarchies).  It should fit for troublesooting.  Then there
> should be no reason to implement two different APIs for observation from
> shell via FS and from applications.

Maybe we can reuse the existing kcmp() system call? We would have to store
the collected pid values in some hash/tree anyway, and kcmp() provides us
good comparing function for doing this.

Like we can call kcmp(pid1, pid2, KCMP_PID, nsfd1, nsfd2) which will mean
"Are tasks with pid1 in namespace pointed by nsfd1 and with pid2 in namespace
nsfd2 the same?"

What do you think?

> However, maybe it is possible to implement not via new syscall but
> by implementation of new symlink in sysfs?  Then both ps-like tool and
> CRIU-like tool is able to obtain the ns information by the same means.
> Maybe sort of a symlink to a parent namespace or a process which is
> inside of the parent namespace?  Then a process may identify IDs using
> following steps:
> 
> 1) identify target NS by walking current procfs
> 2) do setns(2)/chroot(2)
> 3) look at procfs to identify target IDs in the target NS

Can you elaborate on this? Let's imagine we have picked two tasks with
init_pid_ns' PIDs being 11 and 12 and we've found out using /proc/pid/ns/pid
links that they both live in some non-init pid namespace.

Then we have to look at this ns' proc. It says that there are also two 
tasks -- 2 and 3. How can we determine which pid is which?


By the way, calling setns() doesn't change the pids we see in any proc -- the
namespace proc shows pids for is pinned at proc mount time. Neither you can
mount this other pidns' proc into temporary location after setns, kernel uses 
the pidns task really lives in -- the task_active_pid_ns(). But nonetheless, 
we have the proc we want.

> It would be impossible to identify foreign IDs for unprivileged
> processes, however.

Yes, that would be useful limitation.

Thanks,
Pavel
