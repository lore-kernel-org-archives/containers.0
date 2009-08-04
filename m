From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Mon, 3 Aug 2009 17:56:51 -0700
Message-ID: <2f86c2480908031756j557e7aebmbf7951da6a1aadb0__26256.051407154$1249347507$gmane$org@mail.gmail.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<4A7652E7.4020206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A7652E7.4020206-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Aug 2, 2009 at 8:00 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Ben Blum wrote:
>> + =A0 =A0 }
>> + =A0 =A0 write_unlock(&css_set_lock);
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* We just gained a reference on oldcg by taking it from the=
 task. As
>
> This comment is incorrect, the ref we just got has been dropped by
> the above put_css_set(oldcg).

No, the idea is that even though we had a reference that we already
dropped, we in effect "traded" the newcg to the task for its oldcg,
giving it our reference on newcg and gaining its reference on oldcg. I
believe the cgroup_mutex guarantees that it'll still be there when we
do the trade - perhaps a BUG_ON(tsk->cgroups !=3D oldcg) is wanted
inside the second task_lock section there? At the very least, a
clearer comment.

>> +static int css_set_check_fetched(struct cgroup *cgrp, struct task_struc=
t *tsk,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct css_=
set *cg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct list=
_head *newcg_list)
>> +{
>> + =A0 =A0 struct css_set *newcg;
>> + =A0 =A0 struct cg_list_entry *cg_entry;
>> + =A0 =A0 struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
>> + =A0 =A0 read_lock(&css_set_lock);
>> + =A0 =A0 newcg =3D find_existing_css_set(cg, cgrp, template);
>> + =A0 =A0 if (newcg)
>> + =A0 =A0 =A0 =A0 =A0 =A0 get_css_set(newcg);
>> + =A0 =A0 read_unlock(&css_set_lock);
>> + =A0 =A0 /* doesn't exist at all? */
>> + =A0 =A0 if (!newcg)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>
> I think it's more intuitive to return 1 if found and 0 if not found.

I was sticking with the convention of nonzero return values indicating
failure, as is used everywhere else in this context.
