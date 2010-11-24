From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] cgroup: Remove call to synchronize_rcu in
	cgroup_attach_task
Date: Tue, 23 Nov 2010 18:29:32 -0800
Message-ID: <AANLkTikCbj7eivr0_k--FCD9HqVk8OoOo76mQHctzmSa__43901.118488475$1290565823$gmane$org@mail.gmail.com>
References: <AANLkTi=4-OgPUugnUBaqSU3oC=3wxTjAsOB_Ais3Or+i@mail.gmail.com>
	<1290563018-2804-1-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1290563018-2804-1-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 23, 2010 at 5:43 PM, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
> This patch is similar to what you described. =A0The main differences are
> that I used a new atomic to handle the rmdir case, and I converted
> check_for_release to be callable in softirq context rather than schedule
> work in free_css_set_rcu. =A0Your css_set scanning in rmdir sounds better,
> I'll take another look at that. =A0Is there any problem with disabling ir=
qs
> with spin_lock_irqsave in check_for_release?

free_css_set_rcu needs to take a write lock on css_set_lock to protect the
list_del(&link->cgrp_link_list).  I'll convert it to schedule work, and cha=
nge
the spin_lock_irqsave back to spin_lock.
