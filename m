From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup: Set CGRP_RELEASABLE when adding to a cgroup
Date: Wed, 24 Nov 2010 15:54:38 -0800
Message-ID: <AANLkTimFqJ+qPidS_81DKd7ExSxDG7GNi0gjcUEEq_7j__28023.051741957$1290643435$gmane$org@mail.gmail.com>
References: <AANLkTi=6nwDCdzDz7E2EaAw2pf3KUVjmKMRqGfz5zVhP@mail.gmail.com>
	<1290577024-12347-1-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1290577024-12347-1-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 23, 2010 at 9:37 PM, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
> @@ -364,12 +372,8 @@ static void __put_css_set(struct css_set *cg, int ta=
skexit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *cgrp =3D link->cgrp;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del(&link->cg_link_list);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del(&link->cgrp_link_list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_dec_and_test(&cgrp->count) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 notify_on_release(cgrp)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (taskexit)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(CGR=
P_RELEASABLE, &cgrp->flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (atomic_dec_and_test(&cgrp->count))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_for_release(cgrp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }

We seem to have lost some notify_on_release() checks - maybe move that
to check_for_release()?
> =A0/* Caller must verify that the css is not for root cgroup */
> +void __css_get(struct cgroup_subsys_state *css, int count)
> +{
> + =A0 =A0 =A0 atomic_add(count, &css->refcnt);
> + =A0 =A0 =A0 set_bit(CGRP_RELEASABLE, &css->cgroup->flags);
> +}

Is css_get() the right place to be putting this? It's not clear to me
why a subsystem taking a refcount on a cgroup's state should render it
releasable when it drops that refcount.

Should we maybe clear the CGRP_RELEASABLE flag right before doing the
userspace callback?

Paul
