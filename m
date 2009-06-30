From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: optimization for iog deletion when
	elevator exiting
Date: Tue, 30 Jun 2009 10:14:48 -0700
Message-ID: <e98e18940906301014n146e7146vb5a73c2f33c9e819__7635.18766402758$1246387227$gmane$org@mail.gmail.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-6-git-send-email-vgoyal@redhat.com>
	<4A4850D3.3000700@cn.fujitsu.com> <20090629140631.GA4622@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090629140631.GA4622-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 29, 2009 at 7:06 AM, Vivek Goyal<vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Jun 29, 2009 at 01:27:47PM +0800, Gui Jianfeng wrote:
>> Hi Vivek,
>>
>> There's no need to travel the iocg->group_data for each iog
>> when exiting a elevator, that costs too much. An alternative
>> solution is reseting iocg_id as soon as an io group unlinking
>> from a iocg. Make a decision that whether it's need to carry
>> out deleting action by checking iocg_id.
>>
>
> Thanks Gui. This makes sense to me. We can check iog->iocg_id to determine
> wheter group is still on iocg list or not instead of traversing the list.
>
> Nauman, do you see any issues with the patch?

Looks like this should work. The only iog with zero id is associated
with root group, which gets deleted outside of this function anyways.

>
> Thanks
> Vivek
>
>> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>> =A0block/elevator-fq.c | =A0 29 ++++++++++-------------------
>> =A01 files changed, 10 insertions(+), 19 deletions(-)
>>
>> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
>> index d779282..b26fe0f 100644
>> --- a/block/elevator-fq.c
>> +++ b/block/elevator-fq.c
>> @@ -2218,8 +2218,6 @@ void io_group_cleanup(struct io_group *iog)
>> =A0 =A0 =A0 BUG_ON(iog->sched_data.active_entity !=3D NULL);
>> =A0 =A0 =A0 BUG_ON(entity !=3D NULL && entity->tree !=3D NULL);
>>
>> - =A0 =A0 iog->iocg_id =3D 0;
>> -
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* Wait for any rcu readers to exit before freeing up the =
group.
>> =A0 =A0 =A0 =A0* Primarily useful when io_get_io_group() is called witho=
ut queue
>> @@ -2376,6 +2374,7 @@ remove_entry:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 group_node);
>> =A0 =A0 =A0 efqd =3D rcu_dereference(iog->key);
>> =A0 =A0 =A0 hlist_del_rcu(&iog->group_node);
>> + =A0 =A0 iog->iocg_id =3D 0;
>> =A0 =A0 =A0 spin_unlock_irqrestore(&iocg->lock, flags);
>>
>> =A0 =A0 =A0 spin_lock_irqsave(efqd->queue->queue_lock, flags);
>> @@ -2403,35 +2402,27 @@ done:
>> =A0void io_group_check_and_destroy(struct elv_fq_data *efqd, struct io_g=
roup *iog)
>> =A0{
>> =A0 =A0 =A0 struct io_cgroup *iocg;
>> - =A0 =A0 unsigned short id =3D iog->iocg_id;
>> - =A0 =A0 struct hlist_node *n;
>> - =A0 =A0 struct io_group *__iog;
>> =A0 =A0 =A0 unsigned long flags;
>> =A0 =A0 =A0 struct cgroup_subsys_state *css;
>>
>> =A0 =A0 =A0 rcu_read_lock();
>>
>> - =A0 =A0 BUG_ON(!id);
>> - =A0 =A0 css =3D css_lookup(&io_subsys, id);
>> + =A0 =A0 css =3D css_lookup(&io_subsys, iog->iocg_id);
>>
>> - =A0 =A0 /* css can't go away as associated io group is still around */
>> - =A0 =A0 BUG_ON(!css);
>> + =A0 =A0 if (!css)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> =A0 =A0 =A0 iocg =3D container_of(css, struct io_cgroup, css);
>>
>> =A0 =A0 =A0 spin_lock_irqsave(&iocg->lock, flags);
>> - =A0 =A0 hlist_for_each_entry_rcu(__iog, n, &iocg->group_data, group_no=
de) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 /*
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* Remove iog only if it is still in iocg li=
st. Cgroup
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* deletion could have deleted it already.
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (__iog =3D=3D iog) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_del_rcu(&iog->group_node=
);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __io_destroy_group(efqd, iog);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 if (iog->iocg_id) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 hlist_del_rcu(&iog->group_node);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __io_destroy_group(efqd, iog);
>> =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 spin_unlock_irqrestore(&iocg->lock, flags);
>> +out:
>> =A0 =A0 =A0 rcu_read_unlock();
>> =A0}
>>
>> -- 1.5.4.rc3
>
