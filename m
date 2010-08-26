From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix API thinko
Date: Wed, 25 Aug 2010 19:08:46 -0700
Message-ID: <AANLkTimyUhwRA03=Ee3a3PPQrKuzVYRzhc52K=mV02PR__42306.5002229579$1282788578$gmane$org@mail.gmail.com>
References: <20100805225914.GA26772@redhat.com> <4C5C3985.5060706@us.ibm.com>
	<1281112704.10055.0.camel@x201>
	<20100825143520.9954d3f9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100825143520.9954d3f9.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 25, 2010 at 2:35 PM, Andrew Morton
<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>
> So am I correct to assume that this change is now needed in 2.6.36, and
> unneeded in 2.6.35?
>
> Can it affect the userspace<->kernel API in amy manner? =A0If so, it
> should be backported into earlier kernels to reduce the number of
> incompatible kernels out there.

AFAICS it shouldn't affect any existing APIs, either in-kernel or to
userspace - it just makes the existing function
cgroup_attach_task_current_cg() a specialization of a more generic new
function.

>
> Paul, did you have any comments?

Other than the language being a bit confusing, it seems fine. I'd
probably word the patch description as:

Add cgroup_attach_task_all()

The existing cgroup_attach_task_current_cg() API is called by a thread
to attach another thread to all of its cgroups; this is unsuitable for
cases where a privileged task wants to attach itself to the cgroups
of a less privileged one, since the call must be made from the context
of the target task.

This patch adds a more generic cgroup_attach_task_all() API that
allows both the source task and to-be-moved task to be specified.
cgroup_attach_task_current_cg() becomes a specialization of the more
generic new function.

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
