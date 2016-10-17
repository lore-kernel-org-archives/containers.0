From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
	ptrace_may_access
Date: Mon, 17 Oct 2016 12:33:33 -0500
Message-ID: <87wph6op76.fsf@x220.int.ebiederm.org>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161017172547.GJ14666@pc.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161017172547.GJ14666-J1fxOzX/cBvk1uMJSBkQmQ@public.gmane.org> (Jann Horn's message of
	"Mon, 17 Oct 2016 19:25:47 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org> writes:

> On Mon, Oct 17, 2016 at 11:39:49AM -0500, Eric W. Biederman wrote:
>> 
>> During exec dumpable is cleared if the file that is being executed is
>> not readable by the user executing the file.  A bug in
>> ptrace_may_access allows reading the file if the executable happens to
>> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
>> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
>> 
>> This problem is fixed with only necessary userspace breakage by adding
>> a user namespace owner to mm_struct, captured at the time of exec,
>> so it is clear in which user namespace CAP_SYS_PTRACE must be present
>> in to be able to safely give read permission to the executable.
>> 
>> The function ptrace_may_access is modified to verify that the ptracer
>> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
>> This ensures that if the task changes it's cred into a subordinate
>> user namespace it does not become ptraceable.
>
> This looks good! Basically applies the same rules that already apply to
> EUID/... changes to namespace changes, and anyone entering a user
> namespace can now safely drop UIDs and GIDs to namespace root.

Yes.  It just required the right perspective and it turned out to be
straight forward to solve.  Especially since it is buggy today for
unreadable executables.

> This integrates better in the existing security concept than my old
> patch "ptrace: being capable wrt a process requires mapped uids/gids",
> and it has less issues in cases where e.g. the extra privileges of an
> entering process are the filesystem root or so.
>
> FWIW, if you want, you can add "Reviewed-by: Jann Horn
> <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>".

Will do. Thank you.

Eric
