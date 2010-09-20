From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH][RFC] v2 exec: move core_pattern pipe helper into the
	crashing namespace
Date: Mon, 20 Sep 2010 11:34:00 -0700
Message-ID: <m1eico1cyv.fsf__41556.8793695003$1285012432$gmane$org@fess.ebiederm.org>
References: <20100918012939.GA25046@redhat.com>
	<1284779629-15273-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1284779629-15273-1-git-send-email-wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> (Will
	Drewry's message of "Fri, 17 Sep 2010 22:13:49 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> writes:

> Presently, a core_pattern pipe endpoint will be run in the init
> namespace.  It will receive the virtual pid (task_tgid_vnr->%p) of the
> core dumping process but will have no access to that processes /proc
> without walking the init namespace /proc looking through all the global
> pids until it finds the one it thinks matches.
>
> One option for fixing this is to change the reported pid:
>   https://patchwork.kernel.org/patch/185912/
> However, it's unclear if it is desirable for the core_pattern to run
> outside the namespace.  In particular, it can easily access the mounts
> via /proc/[pid_nr]/root, but if there is a net namespace, it will not
> have access.  (Originally introduced in 2007 in commit
> b488893a390edfe027bae7a46e9af8083e740668 )
>
> Instead, this change implements the more complex option two.  It
> migrates the ____call_usermodehelper() thread into the same namespaces
> as the dumping process.  It does not assign a pid in that namespace so
> the collector will appear to be pid 0 in the namespace.

I like the direction this is going but as structured this looks like a
security exploit waiting to happen.

The pipe process needs to run in the namespaces of the process who set
the core pattern, not in the namespaces of the dumping process.
Otherwise it is possible to trigger a privileged process to run in a
context where it's reality that it expected, causing it to misuse
it's privileges.  Even if we don't have a privilege problem I think
we will have a case of mismatched functionality where the core pattern
will not work as expected.

I believe the solution here is to move the core pattern into the pid
namespace and to capture the namespaces when set, but if the core
pattern hasn't been set to use the core pattern of the parent pid
namespace.

Eric
