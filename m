From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation
Date: Tue, 21 Jul 2009 13:28:50 -0700
Message-ID: <6599ad830907211328w4ada3afboa8fcecfed980ffd0__32439.2052171335$1248208262$gmane$org@mail.gmail.com>
References: <20090721160333.96AA4D3D@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721160333.96AA4D3D@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 21, 2009 at 9:03 AM, Dave Hansen<dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
> Once a structure goes over PAGE_SIZE*2, we see occasional
> allocation failures. =A0Some people have chosen to switch
> over to things like vmalloc() that will let them keep
> array-like access to such a large structures. =A0But,
> vmalloc() has plenty of downsides.
>
> Here's an alternative. =A0I think it's what Andrew was
> suggesting =A0here:
>
> =A0 =A0 =A0 =A0http://lkml.org/lkml/2009/7/2/518

Looks like a useful library abstraction.

As far as using it for the cgroups tasks files, it would be possible,
although I was leaning towards an approach that I expressed in the
thread on Ben's patch to add the "procs" file:

- make css_set and its various linked lists RCU-safe
- make it possible for the cgroup iterator to pause/resume scanning by
leaving a cursor at the relevant point in the css_set lists.

Then we can avoid any memory allocations at all.

The downside is that we lose the current sorted output for the tasks
file; http://www.google.com/codesearch?q=3Dcpuset+tasks suggests that
current users of the tasks file don't expect it to be sorted (and in
fact libcpuset explicitly sorts it after reading) so it's not clear if
this would be a problem. I don't think I can see a plausible scenario
where userspace would be relying on sorted output, but maybe others
can.

Paul
