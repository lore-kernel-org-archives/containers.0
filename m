From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Mon, 13 Jul 2009 11:25:24 -0400
Message-ID: <2f86c2480907130825x7189c713la2f5bd99749926__13809.4826521867$1247499314$gmane$org@mail.gmail.com>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230154.16778.58053.stgit@hastromil.mtv.corp.google.com>
	<4A5AAE02.7060106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A5AAE02.7060106-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Jul 12, 2009 at 11:46 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> I think a better demonstration is:
>
> =A0$ cat tasks
> =A01000
> =A01001
> =A01002
>
> =A0$ cat procs
> =A01000

Indeed.

>> + =A0 =A0 /*
>> + =A0 =A0 =A0* if the length difference is large enough, we want to allo=
cate a
>> + =A0 =A0 =A0* smaller buffer to save memory. if this fails due to out o=
f memory,
>> + =A0 =A0 =A0* we'll just stay with what we've got.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (PIDLIST_REALLOC_DIFFERENCE(length, dest)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 newlist =3D kmalloc(dest * sizeof(pid_t), GFP_=
KERNEL);
>
> krealloc()
>

Ah yes. I had thought about krealloc and determined that it wasn't
clever enough to do in-place resizing, but forgot that it could be
used anyway here.
