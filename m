From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/8] Adds functionality to read/write lock CLONE_THREAD
	fork()ing per-threadgroup
Date: Thu, 20 Aug 2009 14:16:13 -0700
Message-ID: <6599ad830908201416g7362e008u167f232f2bb3f476__43727.220389019$1250803219$gmane$org@mail.gmail.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235843.22531.57310.stgit@menage.mtv.corp.google.com>
	<4A8CB750.7040509@cn.fujitsu.com>
	<6599ad830908191945k7c5f86b6j3ea4194f0dffa9ce@mail.gmail.com>
	<20090820141356.1bec84ed.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090820141356.1bec84ed.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
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
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Aug 20, 2009 at 2:13 PM, Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> w=
rote:
>> >
>> > s/tsk->sighand/p->sighand
>>
>> Good catch, thanks. Fixed.
>>
>
> I see no fix anywhere so I did this:

I meant fixed in my tree to go out in the next set of patches.


>
> --- a/kernel/cgroup.c~cgroups-add-functionality-to-read-write-lock-clone_=
thread-forking-per-threadgroup-fix
> +++ a/kernel/cgroup.c
> @@ -1557,7 +1557,7 @@ struct sighand_struct *threadgroup_fork_
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry_rcu(p, &tsk->thread_gr=
oup, thread_group) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (p->sighand) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sighand =3D=
 tsk->sighand;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sighand =3D=
 p->sighand;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}

Yes, looks good.

Paul
