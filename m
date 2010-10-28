From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Understanding cgroups
Date: Thu, 28 Oct 2010 15:22:20 -0700
Message-ID: <AANLkTinkrVG2fTpPDC1DpcC+CiYWjXdYdqTMO5Tv7Swt__18785.2039387964$1288304597$gmane$org@mail.gmail.com>
References: <4CC99A65.9050706@sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC99A65.9050706-gAmJrWFzCps@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tommaso Cucinotta <tommaso.cucinotta-gAmJrWFzCps@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dhaval Giani <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 28, 2010 at 8:44 AM, Tommaso Cucinotta
<tommaso.cucinotta-gAmJrWFzCps@public.gmane.org> wrote:
> a) why doesn't a cgroup object directly point to a css_set one, but to a
> list of them (via cg_cgroup_list elements) ?

Each task is in one cgroup per mounted hierarchy. There's no
requirement that different hierarchies have isomorphic partitions of
tasks (in fact that would somewhat defeat the point of mounting
separate hierarchies). So even though all the tasks in a cgroup share
css pointers for the subsystems attached to that cgroup's hierarchy,
in general they will have different total sets of css pointers. Hence
the multiple css_set objects associated with a cgroup.

> =A0 =A0it seems that a cgroup object may be associated to multiple css_set
> objects, which in turn contain vectors of
> =A0 =A0cgroup_subsys_state;
> b) however, cgroup.subsys[] would point to a single cgroup_subsys_state
> object per subsys_id,

No, it points to a single cgroup_subsys_state for each subsys that's
bound to the cgroup's hierarchy, and NULL for all others.

> so, what is the
> =A0 =A0difference between cgroup.subsys[] and css_set.subsys[] ? (or, are=
 these
> all redundant pointers and point
> =A0 =A0to the same cgroup_subsys_state objects ?)

css_set.subsys is the union of all the (disjoint) sets of subsys
pointers in the cgroups that a task is a member of (one cgroup per
hierarchy).

Yes, the pointers in the css_set are redundant in that they could be
determined by following more pointers, but for efficiency they're all
available directly in the css_set. (Also this typically allows a
single refcount inc/dec in the task fork/exit case)

> c) is css_set.cg_links used to point to (the head of) a list of
> cg_cgroup_link objects,

Yes. It's the head of a list of cg_cgroup_link objects, each of which
has a pointer to this css_set and a pointer to a cgroup of which this
css_set represents membership. (One per hierarchy)

> or is it used to link multiple css_set objects into
> a list ?

In a way this is also true, but only indirectly - the cg_cgroup_link
objects form a two-dimensional doubly-linked list lattice that
represents the many:many relationship between cgroup and css_set. One
dimension's linked lists are headed by css_set objects, the other
dimension is headed by cgroups.

Paul
