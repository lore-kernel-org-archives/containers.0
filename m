From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: lxc-start: Device or resource busy - failed to remove previous
	cgroup
Date: Mon, 4 Jan 2010 21:27:15 +0530
Message-ID: <661de9471001040757x77e1c7e9q9044a00c943e932f@mail.gmail.com>
References: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
	<661de9471001031722o21c6bd55kb73403c85a8145e3@mail.gmail.com>
	<68e6eac61001031746r44668e6cheb497c7df5f68a18@mail.gmail.com>
	<68e6eac61001031854v35c9b0a0sebce033812977e73@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <68e6eac61001031854v35c9b0a0sebce033812977e73-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

> munmap(0x7feca8220000, 4096) =A0 =A0 =A0 =A0 =A0 =A0=3D 0
> access("/cgroup/arch64-1", F_OK) =A0 =A0 =A0 =A0=3D 0
> rmdir("/cgroup/arch64-1") =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D -1 EBUSY (Devic=
e or resource busy)
> write(2, "lxc-start: "..., 11lxc-start: ) =A0 =A0 =A0 =A0 =A0=3D 11
> write(2, "Device or resource busy - failed "..., 77Device or resource
> busy - failed to remove previous cgroup '/cgroup/arch64-1') =3D 77
> write(2, "\n"..., 1
> ) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D 1

I can't see the create of /cgroup/arch64-1 happening, but the rmdir
fails. Hmmm.. does the group already exist at mount time? What are the
permissions?

Balbir Singh.
