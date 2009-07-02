From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: fix pid namespace bug
Date: Thu, 2 Jul 2009 09:46:51 -0700
Message-ID: <6599ad830907020946r42735c9es642bddf37af755ed__11630.4709612907$1246553881$gmane$org@mail.gmail.com>
References: <4A4C0C60.4050106@cn.fujitsu.com>
	<6599ad830907020926t6305bec9t44a50cc165f6fc28@mail.gmail.com>
	<20090702163731.GA14267@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702163731.GA14267-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 2, 2009 at 9:37 AM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
> =A0 =A0 =A0 =A01. the only way it won't outlive the open file is if the
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task opens the file, hands the open fd ove=
r a
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unix socket, then exits as the last task o=
f its
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pidns

Right.

> =A0 =A0 =A0 =A02. We don't dereference the pid_ns, so there is no actual
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0safety issue. =A0So it would become a prob=
lem only
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if a new pidns gets created at that same a=
ddress

Which is fairly likely given that pid_namespace is allocated from a
specific cache.

Paul
