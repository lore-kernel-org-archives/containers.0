From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 3/5] pidns: Don't have unshare(CLONE_NEWPID) imply
	CLONE_THREAD
Date: Fri, 30 Aug 2013 16:49:40 -0700
Message-ID: <87ppsuviwb.fsf@xmission.com>
References: <87ob8gys0d.fsf@xmission.com> <87a9k0yrvu.fsf@xmission.com>
	<20130830163805.GB18857@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130830163805.GB18857-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 30 Aug 2013 16:38:05 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> 
>> I goofed when I made unshare(CLONE_NEWPID) only work in a
>> single-threaded process.  There is no need for that requirement and in
>> fact I analyzied things right for setns.  The hard requirement
>> is for tasks that share a VM to all be in the pid namespace and
>> we properly prevent that in do_fork.
>
> I don't understand though - copy_process does have the right test:
>
>    1176          * If the new process will be in a different pid namespace
>    1177          * don't allow the creation of threads.
>    1178          */
>    1179         if ((clone_flags & (CLONE_VM|CLONE_NEWPID)) &&
>    1180             (task_active_pid_ns(current) != current->nsproxy->pid_ns))
>    1181                 return ERR_PTR(-EINVAL);
>
> but why is it ok for sys_unshare not to do that?  Note that
> in order for check_unshare_flags() to bail on &current->mm->mm_users > 1
> you do have to set CLONE_VM (for inverse interpretation).
>
> So it seems to me this isn't safe as is, and we need to at least
> set CLONE_VM if CLONE_PID is set.

Partly this is the difference in the meaning of the flags between
unshare and clone.

Basically in unshare all othat gets changed is
current->nsproxy->pid_ns_for_children (the rename is in the net tree).

So because unshare of the pid namespace does not actually effect the
current processes, just the pid namespace the children of the current
thread will be in this is safe.

And frankly having the checks be obviously different is a good thing
because it means that people will ask why in the world this is so and
realize the difference in meaning.

Eric
