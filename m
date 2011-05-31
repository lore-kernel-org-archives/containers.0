From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [TRIVIAL PATCH next 14/15] mm: Convert vmalloc/memset to vzalloc
Date: Tue, 31 May 2011 12:47:27 -0700
Message-ID: <BANLkTikFwfQrvEwHcx5iJe+m8HaGyQ_9BN-0n8C0X5cPjNnOPw__23039.7001411349$1306871958$gmane$org@mail.gmail.com>
References: <cover.1306603968.git.joe@perches.com>
	<f3d616b526e00bd8f01a250b7ce8c5a6e2412768.1306603968.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <f3d616b526e00bd8f01a250b7ce8c5a6e2412768.1306603968.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, May 28, 2011 at 10:36 AM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
> =A0mm/page_cgroup.c | =A0 =A03 +--
> =A01 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 74ccff6..dbb28fd 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -478,11 +478,10 @@ int swap_cgroup_swapon(int type, unsigned long max_=
pages)
> =A0 =A0 =A0 =A0length =3D DIV_ROUND_UP(max_pages, SC_PER_PAGE);
> =A0 =A0 =A0 =A0array_size =3D length * sizeof(void *);
>
> - =A0 =A0 =A0 array =3D vmalloc(array_size);
> + =A0 =A0 =A0 array =3D vzalloc(array_size);
> =A0 =A0 =A0 =A0if (!array)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nomem;
>
> - =A0 =A0 =A0 memset(array, 0, array_size);
> =A0 =A0 =A0 =A0ctrl =3D &swap_cgroup_ctrl[type];
> =A0 =A0 =A0 =A0mutex_lock(&swap_cgroup_mutex);
> =A0 =A0 =A0 =A0ctrl->length =3D length;
> --
> 1.7.5.rc3.dirty
>
>
