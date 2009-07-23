From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Add a back-pointer from struct cg_cgroup_link to
	struct cgroup
Date: Thu, 23 Jul 2009 07:31:34 -0700
Message-ID: <6599ad830907230731v13b18e17vbed373f57f878c85__5814.57277662611$1248359655$gmane$org@mail.gmail.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
	<20090722195040.7481.44939.stgit@menage.mtv.corp.google.com>
	<4A6806D9.8020004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A6806D9.8020004-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 22, 2009 at 11:44 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> I think we need to cgroup_enable_task_cg_lists():
>
> =A0 =A0 =A0 =A0if (!use_task_css_set_links)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cgroup_enable_task_cg_lists();
>
> Otherwise we'll see no tasks when reading this debug file
> if use_task_css_set_links =3D=3D 0.
>

I think that's OK - the debug file should indicate the state of the
kernel, not alter it. If there are no links, then no links should be
printed.

Paul
