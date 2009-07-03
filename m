From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Ensures correct concurrent opening/reading of
	pidlists across pid namespaces
Date: Thu, 2 Jul 2009 17:43:52 -0700
Message-ID: <2f86c2480907021743k5c1aeafeq234da81bb5c9676d__35860.2674132728$1246582382$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232625.3969.54444.stgit@menage.mtv.corp.google.com>
	<20090702165413.f4a21471.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702165413.f4a21471.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 2, 2009 at 4:54 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wr=
ote:
>> +static struct cgroup_pidlist *cgroup_pidlist_find(struct cgroup *cgrp,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 enum cgroup_filetype type)
>> +{
>> + =A0 =A0 struct cgroup_pidlist *l;
>> + =A0 =A0 /* don't need task_nsproxy() if we're looking at ourself */
>> + =A0 =A0 struct pid_namespace *ns =3D get_pid_ns(current->nsproxy->pid_=
ns);
>> + =A0 =A0 mutex_lock(&cgrp->pidlist_mutex);
>> + =A0 =A0 list_for_each_entry(l, &cgrp->pidlists, links) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (l->key.type =3D=3D type && l->key.ns =3D=
=3D ns) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* found a matching list - dro=
p the extra refcount */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_pid_ns(ns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* make sure l doesn't vanish =
out from under us */
>
> This looks fishy.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 down_write(&l->mutex);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&cgrp->pidlist_mu=
tex);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l->use_count++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return l;
>
> The caller of cgroup_pidlist_find() must ensure that l->use_count > 0,
> otherwise cgroup_pidlist_find() cannot safely use `l' - it could be
> freed at any time. =A0But if l->use_count > 0, there is no risk of `l'
> "vanishing out from under us".
>
> I'm probably wrong there, but that's the usual pattern and this code
> looks like it's doing something different. =A0Please check?
>

That comment is vague, and should be rewritten. Individual pidlist
locks depend on the cgroup->pidlist_mutex; the main idea here is that
we can't drop the pidlist_mutex before picking up l->lock in case
somebody's trying to remove it from the list at the same time (compare
with cgroup_release_pid_array, the destroyer). The pid_namespace
refcount is also safe, because having found the existing list means
whoever put it there has a reference on the namespace in l->key, which
hasn't gone away yet and also is protected by the
cgroup->pidlist_mutex.

The only ordering that's important here is that incrementing
l->use_count and dropping cgroup->pidlist_mutex both have to come
after taking l->mutex.
