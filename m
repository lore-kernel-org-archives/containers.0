From: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Subject: Re: [PATCH 3/6] cgroup: introduce cgroup_taskset and use it in
	subsys->can_attach(), cancel_attach() and attach()
Date: Fri, 26 Aug 2011 08:54:42 -0700
Message-ID: <CALdu-PB==1C9NyrbAEqR932DOVLbdtv7Ri9_cUCMiz_PwmvL3g__20636.5947648466$1314374213$gmane$org@mail.gmail.com>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
	<1314312192-26885-4-git-send-email-tj@kernel.org>
	<20110826023818.GC3457@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110826023818.GC3457-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Aug 25, 2011 at 7:38 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, Aug 26, 2011 at 12:43:09AM +0200, Tejun Heo wrote:
>> Currently, there's no way to pass multiple tasks to cgroup_subsys
>> methods necessitating the need for separate per-process and per-task
>> methods. =A0This patch introduces cgroup_taskset which can be used to
>> pass multiple tasks and their associated cgroups to cgroup_subsys
>> methods.
>
> This will be the third iterator-ish pattern in the cgroup code.
> It's not your fault but it does seem a bit much to have:

I agree with this sentiment in principle (in fact it was one of the
first things that I thought when I saw this patch) but I think that
merging them is a non-trivial process, and so shouldn't hold up the
introduction of this patch set.

Changing the cgroup_scanner interface to be control-loop rather than
callback (for the processed tasks, at least - testing tasks will have
to be a callback still, I think) shouldn't be too hard.

The important differences between the iterators then are how they
generate a stable set of tasks. If we made the basic callback
operations be:

start - do any prep work
fill - return some tasks to process, or none if the iterator is exhausted
end - undo any prep work

then the user API functions would look something like:

iter_start(iter *i) {
  i->start();
  i->avail_task_count =3D i->avail_task_pos =3D 0;
}

struct task_and_cgroup *iter_next(iter *i) {
  if (i->avail_task_pos >=3D i->avail_task_count) {
    i->avail_task_pos =3D 0;
    i->fill(&i->avail_tasks, &i->avail_task_count);
    if (!i->avail_tasks)
      return NULL;
    }
  }
  return i->avail_tasks + i->avail_task_pos++;
}

iter_end(iter *i) {
  i->end();
}

then for the three iteration abstractions:

- cgroup_iter_start/next/end:

creation API: taskset_from_cgroup(cgroup *cg)

start - takes the lock
fill - returns the next task in the cgroup, or NULL if exhausted
end - releases the lock

- cgroup_taskset

creation API: taskset_from_array(task_and_cgroup *tg, int count)

start - no-op
fill - returns a pointer to the array used to set up the taskset
end - no-op

- cgroup_scanner

creation API: atomic_taskset_from_array(cgroup, test_fn, optional_heap);

start - allocate an array for storing the heap used to build the next
batch of tasks (if not provided by creator)
fill - takes css_set lock and makes a pass over the cgroup to find the
lowest (by start-time) set of unprocessed tasks that match the test_fn
predicate, releases css_set_lock
end - frees the array (if not provided by the creator)

I think the progression of patches would be:

- convert the current user of cgroup_scanner to a control-loop API
rather than a callback API (for process_task) just to verify that this
fits in the existing model

- convert the initial implementation of cgroup_taskset to use the new
internal start/fill/end API

- convert the other two iterators (in separate patches) to use the new
internal and external APIs.

Paul
