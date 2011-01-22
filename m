From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] cgroup: Remove call to synchronize_rcu in
	cgroup_attach_task
Date: Fri, 21 Jan 2011 18:04:06 -0800
Message-ID: <AANLkTimEA2pjbWgB51GsqofreJtqT7QSr8cQ2xSMCa50__28642.1330216855$1295661977$gmane$org@mail.gmail.com>
References: <AANLkTi=4-OgPUugnUBaqSU3oC=3wxTjAsOB_Ais3Or+i@mail.gmail.com>
	<1290563018-2804-1-git-send-email-ccross@android.com>
	<4D3A3024.9040402@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D3A3024.9040402-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bryan Huntsman <bryanh-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, mbohan-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jan 21, 2011 at 5:17 PM, Bryan Huntsman <bryanh-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wro=
te:
> On 11/23/2010 05:43 PM, Colin Cross wrote:
>> synchronize_rcu can be very expensive, averaging 100 ms in
>> some cases. =A0In cgroup_attach_task, it is used to prevent
>> a task->cgroups pointer dereferenced in an RCU read side
>> critical section from being invalidated by delaying the call
>> to put_css_set until after an RCU grace period.
>>
>> To avoid the call to synchronize_rcu, make the put_css_set
>> call rcu-safe by moving the deletion of the css_set links
>> into rcu-protected free_css_set_rcu.
>>
>> The calls to check_for_release in free_css_set_rcu now occur
>> in softirq context, so convert all uses of the
>> release_list_lock spinlock to irq safe versions.
>>
>> The decrement of the cgroup refcount is no longer
>> synchronous with the call to put_css_set, which can result
>> in the cgroup refcount staying positive after the last call
>> to cgroup_attach_task returns. =A0To allow the cgroup to be
>> deleted with cgroup_rmdir synchronously after
>> cgroup_attach_task, introduce a second refcount,
>> rmdir_count, that is decremented synchronously in
>> put_css_set. =A0If cgroup_rmdir is called on a cgroup for
>> hich rmdir_count is zero but count is nonzero, reuse the
>> rmdir waitqueue to block the rmdir until the rcu callback
>> is called.
>>
>> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
>> ---
>>
>> This patch is similar to what you described. =A0The main differences are
>> that I used a new atomic to handle the rmdir case, and I converted
>> check_for_release to be callable in softirq context rather than schedule
>> work in free_css_set_rcu. =A0Your css_set scanning in rmdir sounds bette=
r,
>> I'll take another look at that. =A0Is there any problem with disabling i=
rqs
>> with spin_lock_irqsave in check_for_release?
>>
>> =A0include/linux/cgroup.h | =A0 =A06 ++
>> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0124 ++++++++++++++++++++++++++++-=
-------------------
>> =A02 files changed, 78 insertions(+), 52 deletions(-)
>>
>
> Colin, what became of this patch? =A0I see this in your Tegra tree for
> Android.
>
> http://android.git.kernel.org/?p=3Dkernel/tegra.git;a=3Dcommit;h=3D05946a=
1e0fdb011ac0e6638ee60b181c584f127b
>
> I looked in linux-next but didn't see it there. =A0This resolves a
> performance issue on MSM SMP so I'm curious if this is going upstream.
> =A0Thanks.
>

It's been posted, there are no outstanding comments I am working on,
but they haven't been picked up.
