From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 0/2] Memory usage limit notification feature (v3)
Date: Tue, 14 Jul 2009 09:31:31 +0900 (JST)
Message-ID: <20090714093023.6280.A69D9226__48227.0514978611$1247531538$gmane$org@jp.fujitsu.com>
References: <1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>
	<6599ad830907131720j4f7e1649y4866d2ddeae862c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5406319814980032787=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907131720j4f7e1649y4866d2ddeae862c5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers Mailing List <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux memory management list <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============5406319814980032787==
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n6E0Vgp2003623

> On Mon, Jul 13, 2009 at 5:16 PM, Vladislav
> Buzov<vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org> wrote:
> >
> > The following sequence of patches introduce memory usage limit notifi=
cation
> > capability to the Memory Controller cgroup.
> >
> > This is v3 of the implementation. The major difference between previo=
us
> > version is it is based on the the Resource Counter extension to notif=
y the
> > Resource Controller when the resource usage achieves or exceeds a con=
figurable
> > threshold.
> >
> > TODOs:
> >
> > 1. Another, more generic notification mechanism supporting different =
=A0events
> > =A0 is preferred to use, rather than creating a dedicated file in the=
 Memory
> > =A0 Controller cgroup.
>=20
> I think that defining the the more generic userspace-API portion of
> this TODO should come *prior* to the new feature in this patch, even
> if the kernel implementation isn't initially generic.

I fully agree this ;-)




--===============5406319814980032787==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5406319814980032787==--
