From: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/11] fuse: Support fuse filesystems outside of
	init_user_ns
Date: Tue, 13 Feb 2018 11:20:07 +0100
Message-ID: <CAOssrKcKz8p9YQJLf2W_NCBo+12auxir5jFwXGbANdWdgavpsw__8033.25967067412$1518517143$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<c85c293e19a478353aba8e6e3ee39e5914f798d5.1512041070.git.dongsu@kinvolk.io>
	<CAOssrKd6vkMDwRT=QQofKCufzQczzQ7dXoVbVfVax-0HqD986w@mail.gmail.com>
	<87lgfy5fpd.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87lgfy5fpd.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 12, 2018 at 5:35 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>
>> On Fri, Dec 22, 2017 at 3:32 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
>>> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>>
>>> In order to support mounts from namespaces other than
>>> init_user_ns, fuse must translate uids and gids to/from the
>>> userns of the process servicing requests on /dev/fuse. This
>>> patch does that, with a couple of restrictions on the namespace:
>>>
>>>  - The userns for the fuse connection is fixed to the namespace
>>>    from which /dev/fuse is opened.
>>>
>>>  - The namespace must be the same as s_user_ns.
>>>
>>> These restrictions simplify the implementation by avoiding the
>>> need to pass around userns references and by allowing fuse to
>>> rely on the checks in inode_change_ok for ownership changes.
>>> Either restriction could be relaxed in the future if needed.
>>
>> Can we not introduce potential userspace interface regressions?
>>
>> The issue with pid namespaces fixed in commit 5d6d3a301c4e ("fuse:
>> allow server to run in different pid_ns") will probably bite us here
>> as well.
>
> Maybe, but unlike the pid namespace no one has been able to mount
> fuse outside of init_user_ns so we are much less exposed.  I agree we
> should be careful.

Have to wrap my head around all the rules here.

There's the may_mount() one:

    ns_capable(current->nsproxy->mnt_ns->user_ns, CAP_SYS_ADMIN)

Um, first of all, why isn't it checking current->cred->user_ns?

Ah, there it is in sget():

    ns_capable(user_ns, CAP_SYS_ADMIN)

I get the plain capable(CAP_SYS_ADMIN) check in sget_userns() if fs
doesn't have FS_USERNS_MOUNT.  This is the one that prevents fuse
mounts from being created when (current->cred->user_ns !=
&init_user_ns).

Maybe there's a logic to this web of namespaces, but I don't yet see
it.  Is it documented somewhere?

>> We basically need two modes of operation:
>>
>> a) old, backward compatible (not introducing any new failure mores),
>> created with privileged mount
>> b) new, non-backward compatible, created with unprivileged mount
>>
>> Technically there would still be a risk from breaking userspace, since
>> we are using the same entry point for both, but let's hope that no
>> practical problems come from that.
>
> Answering from a 10,000 foot perspective:
>
> There are two cases.  Requests to read/write the filesystem from outside
> of s_user_ns.  These run no risk of breaking userspace as this mode has
> not been implemented before.

This comes from the fact that (s_user_ns == &init_user_ns) and all
user namespaces are "inside" init_user_ns, right?

One question: why does current code use the from_[ug]id_munged()
variant, when the conversion can never fail.  Or can it?

> Restrictions at mount time to ensure we are not dealing with a crazy mix
> of namespaces.  This has a small chance of breaking someone's crazy
> setup.
>
>
> Dropping requests to read/write the filesystem when the requester does
> not map into s_user_ns should not be a problem to enable universally.  If
> s_user_ns is init_user_ns everything maps so there is no restriction.
>
>
>
> What we can do if we want to ensure maximum backwards compatibility
> is if the fuse filesystem is mounted in init_user_ns but if device for
> the communication channel is opened in some other user namespace we
> can just force the communication channel to operate in init_user_ns.
>
> That will be 100% backwards compatible in all cases and as far as I can
> see remove the need for having different ``modes'' of operation.

Okay.

Thanks,
Miklos
