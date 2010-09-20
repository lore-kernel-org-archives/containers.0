From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH][RFC] v2 exec: move core_pattern pipe helper into the
	crashing namespace
Date: Mon, 20 Sep 2010 15:26:18 -0500
Message-ID: <AANLkTi=bKdcHdNSy8dQQeHZd0uxeRekSvf9Ronu5KFV___12018.5829153799$1285016172$gmane$org@mail.gmail.com>
References: <20100918012939.GA25046@redhat.com>
	<1284779629-15273-1-git-send-email-wad@chromium.org>
	<m1eico1cyv.fsf@fess.ebiederm.org>
	<20100920191214.GB7496@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100920191214.GB7496-qrUzlfsMFqo/4alezvVtWx2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Sep 20, 2010 at 2:12 PM, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org> wrote:
>> The pipe process needs to run in the namespaces of the process who set
>> the core pattern, not in the namespaces of the dumping process.
>> Otherwise it is possible to trigger a privileged process to run in a
>> context where it's reality that it expected, causing it to misuse
>> it's privileges. =A0Even if we don't have a privilege problem I think
>> we will have a case of mismatched functionality where the core pattern
>> will not work as expected.
>
> For me it seems rather the other way around: running the helper in some
> highly priviledged namespace is more dangerous. If it runs in the
> same context as the crasher it can do the least amount of damage
> relative to the crash process.
>
> And as Will pointed out it's the only sane way to deal with net namespace=
s.


I think you're both right.  How it is implemented right now is an
escape from the linux container. If you allow the root user in a
container to mount proc and update core_pattern, they can escape.
(core_pattern =3D |/well/known/binary_or_scripting_lang)  I'm sure there
are other escapes too (and any umh call is likely an escape like this
one -- e.g., modprobe_path).  That said, using my patch above might
let you traverse a path otherwise blocked by an LSM enforcement (E.g.,
root user runs a process which sets up a vfs namespace with an
encrypted mount and the lsm blocks access to the /proc/[pid]/root -
but core_pattern still runs and with access).

That said, using the setters namespace makes sense to me as a consumer
of core_pattern too. You can set the core_pattern outside of a
chroot/container and collect core dumps there _or_ you can let a
"root" user in a container have their own core collector without
providing a simple escape.  Making format_corename use the correct pid
namespace for translation would make these cases even more seamless.

Unfortunately, I haven't yet looked at doing it that way yet.  The
namespace-transition patch posted is what occurred to me initially.
Perhaps it won't be so hard.  I'll take a look at what it'd take to do
move core_pattern since it'd resolve both the escape/lsm-bypass
scenarios and the mismatch between the arbitrary namespace and the
core_pattern values.

Thanks!
will
