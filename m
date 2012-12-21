From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/11] pidns: Wait in zap_pid_ns_processes until
	pid_ns->nr_hashed == 1
Date: Fri, 21 Dec 2012 16:31:52 +0100
Message-ID: <20121221153152.GA17250@redhat.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
	<1353083750-3621-7-git-send-email-ebiederm@xmission.com>
	<20121219184757.GB22991@redhat.com> <87bodourqt.fsf@xmission.com>
	<20121221141133.GA13805@redhat.com>
	<20121221150238.GA16003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121221150238.GA16003-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/21, Oleg Nesterov wrote:
>
> Once again, the parent namespace injects the task T after ns->reaper
> sees nr_hashed == 1 and returns. Suppose that reaper's parent does
> do_wait() and free_pidmap() clears the bit == 1.
>
> Now, what if T doesn't exit but forks? We must not re-create the
> task with pid_nr == 1 in the dead namespace. Normally this can't
> happen, RESERVED_PIDS logic in alloc_pidmap() saves us. But it
> seems that we need
>
> 	- .extra1 = &zero,
> 	+ .extra1 = &one,
>
> in pid_ns_ctl_table.

Oh, and another problem, or I am totally confused.

T forks and creates the child C1. C1 creates C2. What if C1 exits?
It will try to reparent C2 to the dead/freed ns->child_reaper.

In short. We shouldn't allow alloc_pid() if ns->child_reaper is dying,
I think. nr_hashed == -1 doesn't really work.

Oleg.
