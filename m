From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH][RFC] fs/exec.c: provide the correct process pid to the
	pipe helper
Date: Thu, 16 Sep 2010 16:02:36 -0500
Message-ID: <AANLkTikDDUjvd-hnZ32BiQNc609GdTXtCFtPXrje=zGM__10675.5129331306$1284671056$gmane$org@mail.gmail.com>
References: <1284663599-3549-1-git-send-email-wad@chromium.org>
	<20100916193543.GA11016@redhat.com>
	<m1zkvh4fdc.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1zkvh4fdc.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 16, 2010 at 3:12 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>
>> On 09/16, Will Drewry wrote:
>>>
>>> --- a/fs/exec.c
>>> +++ b/fs/exec.c
>>> @@ -1467,6 +1467,13 @@ static int format_corename(char *corename, long =
signr)
>>> =A0 =A0 =A0char *const out_end =3D corename + CORENAME_MAX_SIZE;
>>> =A0 =A0 =A0int rc;
>>> =A0 =A0 =A0int pid_in_pattern =3D 0;
>>> + =A0 =A0pid_t pid =3D task_tgid_vnr(current);
>>> +
>>> + =A0 =A0/* The pipe helper runs in the init namespace and should
>>> + =A0 =A0 * receive the matching pid until that changes.
>>> + =A0 =A0 */
>>> + =A0 =A0if (ispipe)
>>> + =A0 =A0 =A0 =A0 =A0 =A0pid =3D task_tgid_nr(current);
>>
>> Agreed, it doesn't make sense to pass the "local" pid to the init ns.
>
> Yes, passing the local pid to the init pid namespace doesn't make a lot
> of sense. =A0I have recently fixed unix domain sockets to avoid doing that
> kind of silliness.
>
> That said I don't think this is a complete fix. =A0We also potentially
> have the same issue with the uts namespace and the user namespace.

Hrm true.  I was looking at getting the proper pid to the core handler
as a means for it to get the rest from
/proc/<pid>/[status|mountinfo|root] and so on.  As is, it seemed
non-trivial to reliably walk the /proc tree to find the dumping
process.

> I believe the core file holds all of this information relative to the
> process that is dying, one elf note or other so we don't need to worry
> about information loss.

Yeah - my main concern was /proc access to get information that might
otherwise be lost.

> As for how to implement this for the pid case can we simply grab the
> namespace at the ispipe stage and use task_tgid_nr_ns. =A0Something like:
> pid_ns =3D current->nsproxy->pid_ns;
> if (is_pipe)
> =A0 =A0 =A0 =A0pid_ns =3D &init_pid_ns;
>
> ....
> =A0 =A0 =A0 =A0/* pid */
> =A0 =A0 =A0 =A0case 'p':
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pid_in_pattern =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D snprintf(out_ptr, out_end - out_ptr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"%d", task_tgi=
d_pid_nr_ns(pid_ns, current));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (rc > out_end - out_ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0out_ptr +=3D rc;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;

Would that yield different results than the task_tgid_nr versus vnr,
or is it just cleaner?

> Will you were saying something about complex namespacing (in particular
> the network namespace giving you problems). =A0The network namespace has
> no influence over pipes so how does that come into play?

Ah! All I meant is that this patch lets you access anything that is in
/proc/[tgid]/... for the dumping process.  However, it seems that in
the long run, core_pattern should run the pipe handler inside the
namespace(s) of the process do_coredump is running for.  For instance,
if it wanted to make a network connection on coredump, it'd be doing
it from the init namespace.

> I can imagine that it would be nice to have different core patterns
> depending on where you are in the process tree, so a container can
> do something different than the system outside of the container. =A0Are
> you thinking along those lines, or are you imagining something else?

Yup - in general, I was thinking that even if core_pattern was not
split by namespace, it would be nice to attempt to execute it in the
namespace of the process that needs it.  My understand of namespaces
is that they were a gateway to longer term lightweight containers (as
the patches go into kernel.org) which would mean that a change to
core_pattern shouldn't result in a process running in the init
namespace (at least not by default!).

To that end, I implemented a function similar to your setns() syscall
patch which calls create_new_namespaces (and copy_fs_struct) to create
an unattached fs and nsproxy which I then migrate the
____call_usermodehelper thread over to in umh_setup_pipe.  It leaves
it with a pid of 0, but otherwise functional.  (I also played with
changing its pid or best effort assigning one in the namespace as per
older threads, but it all seemed to fragile.) I can post them on this
thread (or wherever) if you'd like to see them, but they're pretty
trivial, and I'm unsure of their correctness.

cheers!
will
