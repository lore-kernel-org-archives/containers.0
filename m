From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/2] exec: move core_pattern pipe helper into the crashing
	namespace
Date: Fri, 17 Sep 2010 22:14:23 -0500
Message-ID: <AANLkTikjN7Xj5BXLbGEPN2+V9kT1h_z2oifoa-Aw4mK6__14770.8863522441$1284779705$gmane$org@mail.gmail.com>
References: <20100917152639.0e88341a@basil.nowhere.org>
	<1284736618-27153-2-git-send-email-wad@chromium.org>
	<20100918012939.GA25046@redhat.com>
	<AANLkTimsNtoT2GGCv1Zk2cGCsZ17zsOqV1DiF7D5tV=L@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimsNtoT2GGCv1Zk2cGCsZ17zsOqV1DiF7D5tV=L@mail.gmail.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Sep 17, 2010 at 9:34 PM, Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Fri, Sep 17, 2010 at 8:29 PM, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> On 09/17, Will Drewry wrote:
>>>
>>> Instead, this change implements the more complex option two. =A0It
>>> migrates the ____call_usermodehelper() thread into the same namespaces
>>> as the dumping process. =A0It does not assign a pid in that namespace so
>>> the collector will appear to be pid 0.
>>
>> Hmm... You mean, it won't visible in that namespace? Afacis, it should
>> have the correct pid in the init ns, no?
>
> Exactly - it will be unmapped in its new pid namespace, returning 0
> only in that case, as you point out below!
>
>>
>> I am a bit worried task_active_pid_ns() !=3D nsproxy->pid_ns, but perhaps
>> this is OK... Say, sys_getpid() returns 0, strange.
>>
>>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Run the core_collector in the crashing nam=
espaces */
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_namespaces_unattached(0, current,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &pipe_params.nsproxy, &pipe_p=
arams.fs)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "%s faile=
d to copy namespaces\n",
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 argv_free(helper_argv);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_dropcount;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> This looks overcomplicated to me, or I missed something.
>>
>> I do not understand why should we do this beforehand, and why we need
>> copy_namespaces_unattached().
>>
>> Can't you just pass current to umh_pipe_setup() (or another helper) as
>> the argument? Then this helper can copy ->fs and ->nsproxy itself.
>
> I wasn't sure if it was reasonable to pass the current task_struct
> over, but I certainly can.
>
>> In fact, I do not understand why create_new_namespaces() is used. It
>> is called with flags =3D=3D 0 anyway, can't we just do
>>
>> =A0 =A0 =A0 =A0ns =3D coredumping_task->nsproxy;
>> =A0 =A0 =A0 =A0get_nsproxy(ns);
>> =A0 =A0 =A0 =A0switch_task_namespaces(current, ns);
>>
>> ?
>
> So that was my first thought (which I tried). =A0I did exactly what you
> suggested to the khelper thread, and the lack of the fs struct bit me.
> =A0Since the older patch from Eric Biederman (setns()) had taken the
> route of deflecting the work through create_new_namespaces(), I did
> too. =A0I figured it would ensure that any namespacing behavior that
> needed to be done would be done.
>
> In practice, this seems to amount to just adding a refcount to all the
> namespaces and creating a new nsproxy which isn't really needed. =A0Most
> likely, doing what you've suggested above plus the copy_fs_struct and
> the swap out will do the trick. =A0I'll try it out and see. =A0That's make
> it much clearer I think.

That seems to work -- I'll post an update shortly with your comments
and Neil's integrated - hopefully accurately.  Any other thoughts on
style/cleanup/etc will certainly be appreciated.

cheers!
will
