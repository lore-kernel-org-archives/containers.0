From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup: Set CGRP_RELEASABLE when adding to a cgroup
Date: Wed, 24 Nov 2010 16:11:34 -0800
Message-ID: <AANLkTimwvP2Ey1gJ6AbbFNtDKjGZt4cwqL=08nGBa_PT@mail.gmail.com>
References: <AANLkTi=6nwDCdzDz7E2EaAw2pf3KUVjmKMRqGfz5zVhP@mail.gmail.com>
	<1290577024-12347-1-git-send-email-ccross@android.com>
	<AANLkTimFqJ+qPidS_81DKd7ExSxDG7GNi0gjcUEEq_7j@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimFqJ+qPidS_81DKd7ExSxDG7GNi0gjcUEEq_7j-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 24, 2010 at 3:54 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Nov 23, 2010 at 9:37 PM, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
>> @@ -364,12 +372,8 @@ static void __put_css_set(struct css_set *cg, int t=
askexit)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *cgrp =3D link->cgrp;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del(&link->cg_link_list);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del(&link->cgrp_link_list);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_dec_and_test(&cgrp->count) &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 notify_on_release(cgrp)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (taskexit)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(CG=
RP_RELEASABLE, &cgrp->flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_dec_and_test(&cgrp->count))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_for_release(cgrp);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> We seem to have lost some notify_on_release() checks - maybe move that
> to check_for_release()?
check_for_release immediately calls cgroup_is_releasable, which checks
for the same bit as notify_on_release.  There's no need for
CGRP_RELEASABLE to depend on notify_on_release, or to check
notify_on_release before calling check_for_release.

>> =A0/* Caller must verify that the css is not for root cgroup */
>> +void __css_get(struct cgroup_subsys_state *css, int count)
>> +{
>> + =A0 =A0 =A0 atomic_add(count, &css->refcnt);
>> + =A0 =A0 =A0 set_bit(CGRP_RELEASABLE, &css->cgroup->flags);
>> +}
>
> Is css_get() the right place to be putting this? It's not clear to me
> why a subsystem taking a refcount on a cgroup's state should render it
> releasable when it drops that refcount.
I matched the existing behavior, __css_put sets CGRP_RELEASABLE when
refcnt goes to 0.

> Should we maybe clear the CGRP_RELEASABLE flag right before doing the
> userspace callback?
Actually, I think CGRP_RELEASABLE can be dropped entirely.
check_for_release is only called from __css_put, cgroup_rmdir, and
__put_css_set (or free_css_set_work after my second patch).  Those all
imply that __css_get, get_css_set, or cgroup_create have been
previously called, which are the functions that set CGRP_RELEASABLE.
