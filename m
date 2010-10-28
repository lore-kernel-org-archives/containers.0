From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroups: Shrink struct cgroup_subsys
Date: Thu, 28 Oct 2010 16:34:56 -0700
Message-ID: <AANLkTikf-1kLStxqi5UjP=vn3pqVBHy0OA7ibeWTkJ5z__29394.6142461666$1288308930$gmane$org@mail.gmail.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC146BA.7080009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC146BA.7080009-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 22, 2010 at 1:09 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> On x86_32, sizeof(struct cgroup_subsys) shrinks from 276 bytes
> to 264.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Maybe use "bool" here?

Paul

> ---
> include/linux/cgroup.h | =A0 10 ++++++----
> =A01 files changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index ed4ba11..e23ded6 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -481,14 +481,16 @@ struct cgroup_subsys {
> =A0 =A0 =A0 =A0void (*bind)(struct cgroup_subsys *ss, struct cgroup *root=
);
>
> =A0 =A0 =A0 =A0int subsys_id;
> - =A0 =A0 =A0 int active;
> - =A0 =A0 =A0 int disabled;
> - =A0 =A0 =A0 int early_init;
> +
> + =A0 =A0 =A0 unsigned int active:1;
> + =A0 =A0 =A0 unsigned int disabled:1;
> + =A0 =A0 =A0 unsigned int early_init:1;
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * True if this subsys uses ID. ID is not available before=
 cgroup_init()
> =A0 =A0 =A0 =A0 * (not available in early_init time.)
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 bool use_id;
> + =A0 =A0 =A0 unsigned int use_id:1;
> +
> =A0#define MAX_CGROUP_TYPE_NAMELEN 32
> =A0 =A0 =A0 =A0const char *name;
>
> --
> 1.7.0.1
>
>
