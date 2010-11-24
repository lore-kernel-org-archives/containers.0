From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: Convert synchronize_rcu to call_rcu in
	cgroup_attach_task
Date: Tue, 23 Nov 2010 17:24:30 -0800
Message-ID: <AANLkTi=4-OgPUugnUBaqSU3oC=3wxTjAsOB_Ais3Or+i__41026.6441097066$1290562035$gmane$org@mail.gmail.com>
References: <AANLkTikx6d0_VFtZ4zWQucRCf=vFt7N2M6=0jpnKasEE@mail.gmail.com>
	<1290398767-15230-1-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1290398767-15230-1-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
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

On Sun, Nov 21, 2010 at 8:06 PM, Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
> The synchronize_rcu call in cgroup_attach_task can be very
> expensive. =A0All fastpath accesses to task->cgroups that expect
> task->cgroups not to change already use task_lock() or
> cgroup_lock() to protect against updates, and, in cgroup.c,
> only the CGROUP_DEBUG files have RCU read-side critical
> sections.

I definitely agree with the goal of using lighter-weight
synchronization than the current synchronize_rcu() call. However,
there are definitely some subtleties to worry about in this code.

One of the reasons originally for the current synchronization was to
avoid the case of calling subsystem destroy() callbacks while there
could still be threads with RCU references to the subsystem state. The
fact that synchronize_rcu() was called within a cgroup_mutex critical
section meant that an rmdir (or any other significant cgrooup
management action) couldn't possibly start until any RCU read sections
were done.

I suspect that when we moved a lot of the cgroup teardown code from
cgroup_rmdir() to cgroup_diput() (which also has a synchronize_rcu()
call in it) this restriction could have been eased, but I think I left
it as it was mostly out of paranoia that I was missing/forgetting some
crucial reason for keeping it in place.

I'd suggest trying the following approach, which I suspect is similar
to what you were suggesting in your last email

1) make find_existing_css_set ignore css_set objects with a zero refcount
2) change __put_css_set to be simply

if (atomic_dec_and_test(&cg->refcount)) {
  call_rcu(&cg->rcu_head, free_css_set_rcu);
}

3) move the rest of __put_css_set into a delayed work struct that's
scheduled by free_css_set_rcu

4) Get rid of the taskexit parameter - I think we can do that via a
simple flag that indicates whether any task has ever been moved into
the cgroup.

5) Put extra checks in cgroup_rmdir() such that if it tries to remove
a cgroup that has a non-zero refcount, it scans the cgroup's css_sets
list - if it finds only zero-refcount entries, then wait (via
synchronize_rcu() or some other appropriate means, maybe reusing the
CGRP_WAIT_ON_RMDIR mechanism?) until the css_set objects have been
fully cleaned up and the cgroup's refcounts have been released.
Otherwise the operation of moving the last thread out of a cgroup and
immediately deleting the cgroup would very likely fail with an EBUSY

Paul
