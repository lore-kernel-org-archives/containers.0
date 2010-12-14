From: ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Tue, 14 Dec 2010 09:17:25 -0800 (PST)
Message-ID: <519912.19452.qm@web34204.mail.mud.yahoo.com>
References: <4D07398D.9050002@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D07398D.9050002-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


The uid is already root as below,

$ id
uid=3D0(root) gid=3D0(root) groups=3D0(root)


--- On Tue, 12/14/10, Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:

> From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Subject: Re: cgroup tasks file error
> To: "Li Zefan" <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: "ccmail111" <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEmxxBWXNxL4zz@public.gmane.org=
org
> Date: Tuesday, December 14, 2010, 4:31 AM
> On 12/14/2010 02:34 AM, Li Zefan
> wrote:
> > Try:
> > =

> >=A0 =A0 $ sudo echo 580>=A0 tasks
> =

> Hmmm... you probably mean:
> =

> sudo sh -c 'echo 580> tasks'
> =

> Cheers.
> =

> -- Gregory Kurz=A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0=A0=A0gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
> Software Engineer @ IBM/Meiosys=A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 =A0 http://www.ibm.com
> Tel +33 (0)534 638 479=A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0=A0=A0Fax +33 (0)561 400 420
> =

> "Anarchy is about taking complete responsibility for
> yourself."
> =A0 =A0 =A0 =A0 Alan Moore.
> =



      =
