From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix a race condition in manipulating tsk->cg_list
Date: Wed, 16 Apr 2008 21:28:33 -0700
Message-ID: <6599ad830804162128g3d383bc6v606fcd14964bd21e__37860.2006276653$1208406631$gmane$org@mail.gmail.com>
References: <4806C5EB.3040102@cn.fujitsu.com>
	<6599ad830804162118g6b24d8ebq26b0d72133b0e19e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804162118g6b24d8ebq26b0d72133b0e19e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 16, 2008 at 9:18 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>
>  My only thought about the downside of this is that an exiting task
>  that gets stuck somewhere  between setting PF_EXITING and calling
>  cgroup_exit() won't show up in its cgroup's tasks file, since we'll
>  enable cgroup links but skip it. I guess that's not a big deal.
>

How about this as an alternative approach? We can take advantage of
the indirection in tsk->cgroups to create an additional distinguished
css_set that indicates the task has passed the point of checking
tsk->cg_list:

- create a new css_set, called exit_css_set; it has the same cgroup
pointer set as init_css_set.

- in cgroup_exit(), set current->cgroups to &exit_css_set rather than
&init_css_set

- in cgroup_enable_task_cg_list(), ignore any task where p->cgroups ==
&exit_css_set

That way we're synchronizing directly with the task_lock()-protected
section in cgroup_exit(), rather than with the setting of PF_EXITING
at the beginning of do_exit().

Paul
