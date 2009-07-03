From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Thu, 2 Jul 2009 17:31:38 -0700
Message-ID: <2f86c2480907021731h13e0bb95q94f06829eded9aa6__43967.1250911944$1246581152$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702164649.303c4952.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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

On Thu, Jul 2, 2009 at 4:46 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wr=
ote:
>> +/**
>> + * pidlist_uniq - given a kmalloc()ed list, strip out all duplicate ent=
ries
>> + * returns -ENOMEM if the malloc fails; 0 on success
>> + */
>
> The comment purports to be kerneldoc ("/**") but didn't document the
> function's arguments.

Wasn't aware of that restriction. Recommend making
scripts/checkpatch.pl look for that sort of thing?

>> + =A0 =A0 list =3D *p;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* we presume the 0th element is unique, so i starts at 1. t=
rivial
>> + =A0 =A0 =A0* edge cases first; no work needs to be done for either
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (*length =3D=3D 0 || *length =3D=3D 1)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 for (i =3D 1; i < *length; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(list[i] =3D=3D PIDLIST_VALUE_NONE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (list[i] =3D=3D list[last]) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list[i] =3D PIDLIST_VALUE_NONE;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 last =3D i;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> + =A0 =A0 newlist =3D kmalloc(count * sizeof(pid_t), GFP_KERNEL);
>
> What is the maximum possible value of `count' here?
>
> Is there any way in which malicious code can exploit the potential
> multiplicative overflow in this statement? =A0(kcalloc() checks for
> this).
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If cgroup gets more users after we read count, we won't h=
ave
>> + =A0 =A0 =A0* enough space - tough. =A0This race is indistinguishable t=
o the
>> + =A0 =A0 =A0* caller from the case that the additional cgroup users did=
n't
>> + =A0 =A0 =A0* show up until sometime later on.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 length =3D cgroup_task_count(cgrp);
>> + =A0 =A0 array =3D kmalloc(length * sizeof(pid_t), GFP_KERNEL);
>
> max size?
>
> overflowable?

In the first snippet, count will be at most equal to length. As length
is determined from cgroup_task_count, it can be no greater than the
total number of pids on the system. (Also, the second snippet of code
was there before, just relocated, so if there's an overflow bug in
either it'll have already been there.)

>> @@ -2389,21 +2457,27 @@ static int cgroup_write_notify_on_release(struct=
 cgroup *cgrp,
>> =A0/*
>> =A0 * for the common functions, 'private' gives the type of file
>> =A0 */
>> +/* for hysterical reasons, we can't put this on the older files */
>
> "raisins" ;)

They keys are right next to each other, I promise.

There was a bit of discussion on how to name these files. Paul wanted
to start naming the generic cgroup files with the "cgroup." prefix,
but we can't change "tasks" and "notify_on_release" etc. We decided to
use the new name format but only for the new file - can anything be
done about the other ones, or do they have to stay as is?
