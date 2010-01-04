From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc-start: Device or resource busy - failed to remove previous
	cgroup
Date: Mon, 4 Jan 2010 09:21:42 -0600
Message-ID: <68e6eac61001040721m250c0f14u9c07d04ef9ec3648@mail.gmail.com>
References: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
	<661de9471001031722o21c6bd55kb73403c85a8145e3@mail.gmail.com>
	<68e6eac61001031746r44668e6cheb497c7df5f68a18@mail.gmail.com>
	<68e6eac61001031854v35c9b0a0sebce033812977e73@mail.gmail.com>
	<4B41C5A4.704@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B41C5A4.704-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 4, 2010 at 4:40 AM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wro=
te:
> Did you check the file /cgroup/<name>/tasks is empty ? it's probably a du=
mb
> question, but just in case :)
>

Ok, since this is easy enough to reproduce, I got it into this state again.

$ cat /cgroup/arch64-1/tasks
$

it is empty

> Can you give the content of cat /proc/slabinfo =A0| grep namespace ? Does=
 the
> number of objects reach zero ? (assuming you have just one container).
>

cat /proc/slabinfo  | grep namespace
pid_namespace          4      6   2112    3    2 : tunables   24   12
  8 : slabdata      2      2      0
net_namespace          0      0   1984    2    1 : tunables   24   12
  8 : slabdata      0      0      0

I have two containers, but only one was started and stopped this session.

> Maybe I am missing something, but I suspect a bug in the kernel. Can you
> check if that happens with a more recent kernel ?

Ok, yes, I'll do that.

Dwight
