From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
	ptrace_may_access
Date: Tue, 18 Oct 2016 16:07:27 -0500
Message-ID: <87r37dnz74.fsf__36079.2115367532$1476825007$gmane$org@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161018191206.GA1210-GiL72Q0nGm9Crx9znvW9yA@public.gmane.org> (Jann Horn's message of
	"Tue, 18 Oct 2016 21:12:06 +0200")
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org> writes:

> On Tue, Oct 18, 2016 at 10:35:23AM -0500, Eric W. Biederman wrote:
>> Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org> writes:
>> 
>> > On Tue, Oct 18, 2016 at 09:56:53AM -0500, Eric W. Biederman wrote:
>> >> Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
>> >> 
>> >> > On Mon 17-10-16 11:39:49, Eric W. Biederman wrote:
>> >> >> 
>> >> >> During exec dumpable is cleared if the file that is being executed is
>> >> >> not readable by the user executing the file.  A bug in
>> >> >> ptrace_may_access allows reading the file if the executable happens to
>> >> >> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
>> >> >> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
>> >> >> 
>> >> >> This problem is fixed with only necessary userspace breakage by adding
>> >> >> a user namespace owner to mm_struct, captured at the time of exec,
>> >> >> so it is clear in which user namespace CAP_SYS_PTRACE must be present
>> >> >> in to be able to safely give read permission to the executable.
>> >> >> 
>> >> >> The function ptrace_may_access is modified to verify that the ptracer
>> >> >> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
>> >> >> This ensures that if the task changes it's cred into a subordinate
>> >> >> user namespace it does not become ptraceable.
>> >> >
>> >> > I haven't studied your patch too deeply but one thing that immediately 
>> >> > raised a red flag was that mm might be shared between processes (aka
>> >> > thread groups). What prevents those two to sit in different user
>> >> > namespaces?
>> >> >
>> >> > I am primarily asking because this generated a lot of headache for the
>> >> > memcg handling as those processes might sit in different cgroups while
>> >> > there is only one correct memcg for them which can disagree with the
>> >> > cgroup associated with one of the processes.
>> >> 
>> >> That is a legitimate concern, but I do not see any of those kinds of
>> >> issues here.
>> >> 
>> >> Part of the memcg pain comes from the fact that control groups are
>> >> process centric, and part of the pain comes from the fact that it is
>> >> possible to change control groups.  What I am doing is making the mm
>> >> owned by a user namespace (at creation time), and I am not allowing
>> >> changes to that ownership. The credentials of the tasks that use that mm
>> >> may be in the same user namespace or descendent user namespaces.
>> >> 
>> >> The core goal is to enforce the unreadability of an mm when an
>> >> non-readable file is executed.  This is a time of mm creation property.
>> >> The enforcement of which fits very well with the security/permission
>> >> checking role of the user namespace.
>> >
>> > How is that going to work? I thought the core goal was better security for
>> > entering containers.
>> 
>> The better security when entering containers came from fixing the the
>> check for unreadable files.  Because that is fundamentally what
>> the mm dumpable settings are for.
>
> Oh, interesting.
>
>
>> > If I want to dump a non-readable file, afaik, I can just make a new user
>> > namespace, then run the file in there and dump its memory.
>> > I guess you could fix that by entirely prohibiting the execution of a
>> > non-readable file whose owner UID is not mapped. (Adding more dumping
>> > restrictions wouldn't help much because you could still e.g. supply a
>> > malicious dynamic linker if you control the mount namespace.)
>> 
>> That seems to be a part of this puzzle I have incompletely addressed,
>> thank you.
>> 
>> It looks like I need to change either the owning user namespace or
>> fail the exec.  Malicious dynamic linkers are doubly interesting.
>> 
>> As mount name spaces are also owned if I have privileges I can address
>> the possibility of a malicious dynamic linker that way.  AKA who cares
>> about the link if the owner of the mount namespace has permissions to
>> read the file.
>
> If you just check the owner of the mount namespace, someone could still
> use a user namespace to chroot() the process. That should also be
> sufficient to get the evil linker in. I think it really needs to be the
> user namespace of the executing process that's checked, not the user
> namespace associated with some mount namespace.

Something.  I will just note that this is hard to analyze and
theoretically possible for now, since I don't intend to pursue
that solution.

>> I am going to look at failing the exec if the owning user namespace
>> of the mm would not have permissions to read the file.  That should just
>> be a couple of lines of code and easy to maintain.  Plus it does not
>> appear that non-readable executables are particularly common.
>
> Hm. Yeah, I guess mode 04111 probably isn't sooo common.
> From a security perspective, I think that should work.

Well there is at least one common distro that installs sudo
that way so I would not say uncommon.   But we already ignore
the suid and sgid bit when executing such executables as without
having the uid or gid mapping into a user namespace suid and sgid
can not be supported.

So the only case that could cause a real regression/loss of
functionality is if there are unreadable executables without the suid or
sgid bit set.  I can't find any of those.

Patch for this second bug in a moment.

Eric
