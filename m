From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm] cgroup: fix typo in error handling in
	cgroup_write_event_control()
Date: Wed, 24 Feb 2010 08:04:08 -0800
Message-ID: <6599ad831002240804m66adc27fy253e2b10d9867465__15033.0856944949$1267027710$gmane$org@mail.gmail.com>
References: <1267018268-16254-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267018268-16254-1-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 24, 2010 at 5:31 AM, Kirill A. Shutemov
<kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:
> Actually, we want to fput() cfile, if cfile is not NULL.
>
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Thanks.

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
> =A0kernel/cgroup.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index d142524..049ce0d 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -3117,7 +3117,7 @@ static int cgroup_write_event_control(struct cgroup=
 *cgrp, struct cftype *cft,
> =A0 =A0 =A0 =A0return 0;
>
> =A0fail:
> - =A0 =A0 =A0 if (!cfile)
> + =A0 =A0 =A0 if (cfile)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fput(cfile);
>
> =A0 =A0 =A0 =A0if (event && event->eventfd && !IS_ERR(event->eventfd))
> --
> 1.6.6.2
>
>
