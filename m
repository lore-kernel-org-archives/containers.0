From: Paul Menage <menage@google.com>
Subject: Re: [PATCH 1/2] cgroups: Fix to return errno in a failure path
Date: Tue, 26 Jan 2010 15:01:26 -0800
Message-ID: <6599ad831001261501q2e6e54bckebb3d2d225ecc126@mail.gmail.com>
References: <4B5EA4EC.8020700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752649Ab0AZXBd@vger.kernel.org>
In-Reply-To: <4B5EA4EC.8020700@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 26, 2010 at 12:16 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

> ---
> =A0cgroup.c | =A0 =A07 +++++--
> =A01 file changed, 5 insertions(+), 2 deletions(-)
>
> --- a/kernel/cgroup.c.orig =A0 =A0 =A02010-01-19 16:37:37.000000000 +=
0800
> +++ a/kernel/cgroup.c =A0 2010-01-19 16:39:07.000000000 +0800
> @@ -3279,14 +3279,17 @@ static long cgroup_create(struct cgroup
>
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys_state *css =3D ss=
->create(ss, cgrp);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(css)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_destroy;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0init_cgroup_css(css, ss, cgrp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->use_id)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (alloc_css_id(ss, pa=
rent, cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->use_id) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D alloc_css_id(ss=
, parent, cgrp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto e=
rr_destroy;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* At error, ->destroy() callback has =
to free assigned ID. */
> =A0 =A0 =A0 =A0}
>
>
