From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 8/9] [RFC] Example multi-bindable subsystem: a per-cgroup
	notes field
Date: Mon, 13 Jul 2009 17:49:56 -0700
Message-ID: <6599ad830907131749i171f664ey878d6c778132c290__1516.41180641509$1247532822$gmane$org@mail.gmail.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021133.14469.35140.stgit@menage.mtv.corp.google.com>
	<4A4DC81B.3050608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A4DC81B.3050608-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jul 3, 2009 at 1:58 AM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> If it's not per cgroup, it can be a global value.

No it can't, since the notes subsystem can be mounted on multiple
hierarchies simultaneously.

> But why not make it per cgroup?

Setting notes.size to a large value allows userspace to create large
kmalloc'd objects; so if it's per-cgroup, then it's not safe to
delegate control of part of a cgroups hierarchy to untrusted users.
(E.g. we want to be able to give an untrusted user process the power
to create sub-cgroups in the CPU scheduler hierarchy, so that it can
give different CPU guarantees to each of its threadpools).

I guess that an alternative would be to have a per-cgroup size field,
and use the min of the cgroup and all its ancestors when doing length
checking.

>> + =A0 =A0 if (nbytes > cg_info(cgrp->top_cgroup)->max_len)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -E2BIG;
>> + =A0 =A0 if (nbytes) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 notes =3D kmalloc(nbytes, GFP_USER);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!notes)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(notes, userbuf, nbytes))
>
> missing kfree(notes)
>

Good catch, thanks. Fixed (and all the newlines added).

Paul
