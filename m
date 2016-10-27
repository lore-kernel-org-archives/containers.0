From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [REVIEW][PATCH v2] mm: Add a user_ns owner to mm_struct and fix
	ptrace permission checks
Date: Thu, 27 Oct 2016 14:27:01 -0700
Message-ID: <CAGXu5jLYJe0hu5KKvphJL8tfZNmbTZfyXF_ck8zw3HsB-TOfvA__18318.4320027523$1477603658$gmane$org@mail.gmail.com>
References: <20161024105959.GQ1847@uranus.lan> <8760oh8tbp.fsf@xmission.com>
	<20161024202925.GS1847@uranus.lan>
	<CAGXu5jK4p4bbQU1Bu-p9aM1GJ+CAR-FAHZcXXRH0De_M4VQ3wA@mail.gmail.com>
	<8760oh737b.fsf@xmission.com> <20161025090213.GX1847@uranus.lan>
	<87d1ilrdmt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d1ilrdmt.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Andrey Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 27, 2016 at 8:54 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> During exec dumpable is cleared if the file that is being executed is
> not readable by the user executing the file.  A bug in
> ptrace_may_access allows reading the file if the executable happens to
> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
>
> This problem is fixed with only necessary userspace breakage by adding
> a user namespace owner to mm_struct, captured at the time of exec, so
> it is clear in which user namespace CAP_SYS_PTRACE must be present in
> to be able to safely give read permission to the executable.
>
> The function ptrace_may_access is modified to verify that the ptracer
> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
> This ensures that if the task changes it's cred into a subordinate
> user namespace it does not become ptraceable.
>
> The function ptrace_attach is modified to only set PT_PTRACE_CAP when
> CAP_SYS_PTRACE is held over task->mm->user_ns.  The intent of
> PT_PTRACE_CAP is to be a flag to note that whatever permission changes
> the task might go through the tracer has sufficient permissions for
> it not to be an issue.  task->cred->user_ns is always the same
> as or descendent of mm->user_ns.  Which guarantees that having
> CAP_SYS_PTRACE over mm->user_ns is the worst case for the tasks
> credentials.
>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Fixes: 8409cca70561 ("userns: allow ptrace from non-init user namespaces")
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Thanks!

Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

-Kees

-- 
Kees Cook
Nexus Security
