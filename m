From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 11/11] pidns: Support unsharing the pid namespace.
Date: Wed, 21 Nov 2012 10:55:13 +0800
Message-ID: <50AC4291.7010108@cn.fujitsu.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
	<1353083750-3621-11-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353083750-3621-11-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

on 2012/11/17 00:35, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Unsharing of the pid namespace unlike unsharing of other namespaces
> does not take affect immediately.  Instead it affects the children
> created with fork and clone.  The first of these children becomes the init
> process of the new pid namespace, the rest become oddball children
> of pid 0.  From the point of view of the new pid namespace the process
> that created it is pid 0, as it's pid does not map.
> 
> A couple of different semantics were considered but this one was
> settled on because it is easy to implement and it is usable from
> pam modules.  The core reasons for the existence of unshare.
> 
> I took a survey of the callers of pam modules and the following
> appears to be a representative sample of their logic.
> {
> 	setup stuff include pam
> 	child = fork();
> 	if (!child) {
> 		setuid()
>                 exec /bin/bash
>         }
>         waitpid(child);
> 
>         pam and other cleanup
> }
> 
> As you can see there is a fork to create the unprivileged user
> space process.  Which means that the unprivileged user space
> process will appear as pid 1 in the new pid namespace.  Further
> most login processes do not cope with extraneous children which
> means shifting the duty of reaping extraneous child process to
> the creator of those extraneous children makes the system more
> comprehensible.
> 
> The practical reason for this set of pid namespace semantics is
> that it is simple to implement and verify they work correctly.
> Whereas an implementation that requres changing the struct
> pid on a process comes with a lot more races and pain.  Not
> the least of which is that glibc caches getpid().
> 
> These semantics are implemented by having two notions
> of the pid namespace of a proces.  There is task_active_pid_ns
> which is the pid namspace the process was created with
> and the pid namespace that all pids are presented to
> that process in.  The task_active_pid_ns is stored
> in the struct pid of the task.
> 
> Then there is the pid namespace that will be used for children
> that pid namespace is stored in task->nsproxy->pid_ns.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---

Acked-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
