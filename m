From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/7] cgroups: Allow to bind a subsystem to a cgroup
	hierarchy
Date: Thu, 28 Oct 2010 16:55:32 -0700
Message-ID: <AANLkTimCD90s+y_6y=LyOL1QqEOOAaT+b2b4guDrzo_g@mail.gmail.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC146D4.7030009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC146D4.7030009-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Fri, Oct 22, 2010 at 1:09 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Indicate if this subsystem can be bound/unbound to/fro=
m a cgroup
> + =A0 =A0 =A0 =A0* hierarchy which has child cgroups.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 unsigned int can_bind:1;

Maybe call this "bindable"?

Basic idea looks great, it could do with a bunch more comments, and
maybe locking rules.

Is there any chance of a lock inversion between dir->i_mutex and
cgroup_lock in hierarchy_popuiate_dir() ?

Paul
