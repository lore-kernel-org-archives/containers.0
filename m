From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/7] cgroups: Allow to bind/unbind subsystems to/from
	non-trival hierarchy
Date: Thu, 28 Oct 2010 16:33:41 -0700
Message-ID: <AANLkTin9Lzvqw_Dz6b6mywFAOLfoK0P_EfHN9Nchec9j__4259.88003048605$1288308872$gmane$org@mail.gmail.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <1287751801.15336.35.camel@twins>
	<4CC4D84C.5000705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC4D84C.5000705-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Oct 24, 2010 at 6:07 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> Paul had a patch to allow some subsystems to be added to multi-hierarchies,
> which may help.

I more or less dropped it since I couldn't see a big use for it - all
the examples I had were more easily implemented as basic cgroup
control files (and hence available in all hierarchies automatically)

> But it forbids accessing t->cgroups, which makes this
> feature of limited use.

Not exactly - it meant that you couldn't do a fast dereference via
t->cgroups to get to your cgroup_subsys_state, since there was no
longer a unique css for each task for that subsystem - there would be
one per mounted instance of the subsystem. Instead it became necessary
to follow a chain of pointers to find the appropriate css for the
hierarchy in question.

In general this also means that it's harder for the multi-bound
subsystem have any real-world meaning - it's mostly useful for
stateless subsystems, or ones where the cgroup_subsys_state contents
have no direct connection with machine-wide data.

Paul
