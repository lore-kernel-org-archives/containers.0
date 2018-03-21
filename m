From: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v9 0/4] fuse: mounts from non-init user namespaces
Date: Wed, 21 Mar 2018 09:38:46 +0100
Message-ID: <CAOssrKf8_zhw+J_B59wkJ9zj-adRj_f3B4hDUq1CPSF30mX0nQ__24388.0747737878$1521621419$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<878tbmf5vl.fsf@xmission.com>
	<87po4rz4ui.fsf_-_@xmission.com> <87r2p287i8.fsf_-_@xmission.com>
	<87ina6ntx0.fsf_-_@xmission.com>
	<CAOssrKebhX-nm06RAwep8HUUV4QpsAa=ZOgxdRyP=WF9p-=4Tw@mail.gmail.com>
	<87tvta38lu.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tvta38lu.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 20, 2018 at 7:27 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

>> I did just one modification to "fuse: Fail all requests with invalid
>> uids or gids": instead of zeroing out the context for the nofail case,
>> continue to use the "_munged" variants. I don't think this hurts and
>> is better for backward compatibility (I guess the only relevant use
>> would be for debugging output, but we don't want to regress even for
>> that if not necessary)
>
> Hmm...
>
> The thing is the failure doesn't come in the difference between the
> _munged and the normal variants.  The difference between
> munged and non-munged variants is how they handled failure ((uid16_t)-2)
> aka 0xfffe for munged and -1 for the non-munged case.
>
> The failures are introduced by changing &init_user_ns to fc->user_ns.

Right.

> The operations in question are iop->flush and fuse_force_forget (on an
> error).   I don't know what value having ids on those paths will do
> they are operations that must succeed, and they should not change the
> on-disk ids.  I was thinking saying the most privileged id was asking
> for the oepration would seem to make sense.

I don't think anybody should actually *care* about the id's in flush,
but I'd still not change the current behavior for change's sake.

>
> With the munged variants we will get (uid16_t)-2 aka 0xfffe aka
> nobody asking for the operation if things don't map.  In practice
> the don't map case is new.
>
> Since the id's should not be looked at anyway I don't see it makes
> much difference which ids we use so the munged case seems at least
> plausible.
>
> It might be better to use the non-munghed variant and do:
>         if (req->in.h.uid == (uid_t)-1)
>                 req.in.h.uid = 0;
>         if (req->in.h.gid == (gid_t)-1)
>                 req.in.h.gid = 0;
>
> That might be less surprising to userspace.  As I don't think the
> unmapped case has ever occurred in practice yet.

Right, that would work too, but I don't think it actually matters, so
unless you can think of an actual security issue arising from using
the munged variants, I'd just leave it as it is.

Thanks,
Miklos
