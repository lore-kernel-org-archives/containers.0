From: Nick Piggin <npiggin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: linux-next: lockdep whinge in cgroup_rmdir
Date: Fri, 14 Jan 2011 15:10:31 +1100
Message-ID: <AANLkTikHdKf5_gtTTPY9z+ymyPP6enc3S_-d_zdzmLDJ__22832.9950398349$1294978358$gmane$org@mail.gmail.com>
References: <12545.1294932849@localhost>
	<AANLkTikEYgsOjVhmuVCM8rzGRrQxRM0FO475=CEBEtxD@mail.gmail.com>
	<4D2FCBDC.5040107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D2FCBDC.5040107-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jan 14, 2011 at 3:06 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Nick Piggin wrote:
>> It looks like it is just a missing parent->child lock order annotation, =
but
>> mainline cgroupfs code looks to be OK there. What does
>> cgroup_clear_directory() look like in mmotm?
>
> It's not from cgroup_clear_directory()..
>
> This should fix it:

Yep, thanks!

> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
>
> From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Date: Fri, 14 Jan 2011 11:34:34 +0800
> Subject: [PATCH] cgroups: Fix a lockdep warning at cgroup removal
>
> Commit 2fd6b7f5 ("fs: dcache scale subdirs") forgot to annotate a dentry
> lock, which caused a lockdep warning.
>
> Reported-by: Valdis Kletnieks <Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> =A0kernel/cgroup.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 5c5f4cc..db983e2 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -910,7 +910,7 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
>
> =A0 =A0 =A0 =A0parent =3D dentry->d_parent;
> =A0 =A0 =A0 =A0spin_lock(&parent->d_lock);
> - =A0 =A0 =A0 spin_lock(&dentry->d_lock);
> + =A0 =A0 =A0 spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
> =A0 =A0 =A0 =A0list_del_init(&dentry->d_u.d_child);
> =A0 =A0 =A0 =A0spin_unlock(&dentry->d_lock);
> =A0 =A0 =A0 =A0spin_unlock(&parent->d_lock);
> --
> 1.7.3.1
>
>
