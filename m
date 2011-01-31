From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/4] pidns: Use task_active_pid_ns where appropriate
Date: Mon, 31 Jan 2011 13:26:42 +0200
Message-ID: <AANLkTikjcou-0b4NejpY66qXeZuzsC-M+oNTyHk=OE-Z__5601.97671079567$1296473395$gmane$org@mail.gmail.com>
References: <1296469525-30111-1-git-send-email-daniel.lezcano@free.fr>
	<1296469525-30111-5-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296469525-30111-5-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 31, 2011 at 12:25 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> w=
rote:
> The expressions tsk->nsproxy->pid_ns and task_active_pid_ns
> aka ns_of_pid(task_pid(tsk)) should have the same number of
> cache line misses with the practical difference that
> ns_of_pid(task_pid(tsk)) is released later in a processes life.
>
> Furthermore by using task_active_pid_ns it becomes trivial
> to write an unshare implementation for the the pid namespace.
>
> So I have used task_active_pid_ns everywhere I can.

Yet current->nsproxy->pid_ns is way clearer.
Because live current always has pid_ns.

This task_active_pid_ns() is misnamed(?) because it does matter only
for dead tasks?

> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->nsproxy->pid_ns->last_pid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_active_pid_ns(current)->last_pid);

I thought of doing exactly opposite patch :-)
