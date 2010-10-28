From: Dhaval Giani <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Understanding cgroups
Date: Thu, 28 Oct 2010 19:39:44 +0200
Message-ID: <AANLkTimrSxANNzYF3AYf1uhC3SGW7c3Tf=ksBn-QUobP__44357.9260296703$1288288281$gmane$org@mail.gmail.com>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

[Adding a few more people and the containers to the copy]

On Thu, Oct 28, 2010 at 5:44 PM, Tommaso Cucinotta
<tommaso.cucinotta-gAmJrWFzCps@public.gmane.org> wrote:
> Hi,
>
> I'm trying to get some understanding of the current cgroups in-kernel
> implementation
> (after having read Documentation/cgroup* and having browsed a bit the cod=
e).
> To this purpose, I tried to draw the relationships among the involved data
> structures
> (I'm limited to its relationship with [real-time] scheduling), and obtain=
ed
> this:
>
> =A0http://retis.sssup.it/~tommaso/cgroups.odg
> =A0http://retis.sssup.it/~tommaso/cgroups.eps
>
> (You can see in the bottom left part of the diagram a little
> "key/legend/pattern" for representing lists).
>
> I might have done mistakes, however the greatest doubts that I have now
> concern the relative
> cardinalities of the various associated items. Namely:
> a) why doesn't a cgroup object directly point to a css_set one, but to a
> list of them (via cg_cgroup_list elements) ?
> =A0 =A0it seems that a cgroup object may be associated to multiple css_set
> objects, which in turn contain vectors of
> =A0 =A0cgroup_subsys_state;
> b) however, cgroup.subsys[] would point to a single cgroup_subsys_state
> object per subsys_id, so, what is the
> =A0 =A0difference between cgroup.subsys[] and css_set.subsys[] ? (or, are=
 these
> all redundant pointers and point
> =A0 =A0to the same cgroup_subsys_state objects ?)
> c) is css_set.cg_links used to point to (the head of) a list of
> cg_cgroup_link objects, or is it used to link multiple css_set objects in=
to
> a list ? In the latter case, where is the head of the list pointed to fro=
m ?
>
> Apologies for the newbie questions that I might have posted; FYI, I'm try=
ing
> to set-up RT scheduling groups without using the VFS-based cgroups
> interface.
>
> Thanks in advance, regards (please, reply in cc to my e-mail address).
>
> =A0 =A0Tommaso
>
> --
