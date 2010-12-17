From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup: Set CGRP_RELEASABLE when adding to a cgroup
Date: Thu, 16 Dec 2010 16:54:09 -0800
Message-ID: <AANLkTinZarXbEyb1xfJWjG4gN2qhTVTXTdso4Cym5M9T__38660.1899787367$1292547331$gmane$org@mail.gmail.com>
References: <AANLkTi=6nwDCdzDz7E2EaAw2pf3KUVjmKMRqGfz5zVhP@mail.gmail.com>
	<1290577024-12347-1-git-send-email-ccross@android.com>
	<AANLkTimFqJ+qPidS_81DKd7ExSxDG7GNi0gjcUEEq_7j@mail.gmail.com>
	<AANLkTimwvP2Ey1gJ6AbbFNtDKjGZt4cwqL=08nGBa_PT@mail.gmail.com>
	<AANLkTimJA52-GTM=AzS+tkOugrsi6Keh0_j87vK1BkGv@mail.gmail.com>
	<AANLkTim67fLN+PYz-P0TM0QRmvQKP80tyXSNKNSZhFZ2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTim67fLN+PYz-P0TM0QRmvQKP80tyXSNKNSZhFZ2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Thu, Dec 2, 2010 at 7:07 PM, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
>> Not in one case - if we create a new cgroup and try to move a thread
>> into it, but the thread is exiting as we move it, we'll call
>> put_css_set() on the new css_set, which will drop the refcount on the
>> target cgroup back to 0. We wouldn't want the auto-release
>> notification to kick in in that situation, I think.
>
> Clearing the CGRP_RELEASABLE bit any time after the tests in
> check_for_release introduces a race if __css_get is called between the
> check and clearing the bit - the cgroup will have an entry, but the
> bit will not be set. =A0Without additional locking in __css_get, I don't
> see any way to safely clear CGRP_RELEASABLE.

I don't quite follow your argument here. Are you saying that the
problem is that you could end up spawning a release agent for a cgroup
that was no longer releasable since it now had a process in it again?
If so, then I don't think that's a problem - spurious release agent
invocations for non-empty cgroups will always happen occasionally due
to races between the kernel and userspace. But a failed move of a task
into a previously-empty cgroup shouldn't trigger the agent.

Paul
