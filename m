From: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] cgroup: Convert synchronize_rcu to call_rcu in
	cgroup_attach_task
Date: Tue, 23 Nov 2010 00:58:39 -0800
Message-ID: <AANLkTimjpW6NZ6fEiVi0VzjkpQGVob4=VHsohXUiDQkJ__41186.5807058804$1290502811$gmane$org@mail.gmail.com>
References: <AANLkTikx6d0_VFtZ4zWQucRCf=vFt7N2M6=0jpnKasEE@mail.gmail.com>
	<1290398767-15230-1-git-send-email-ccross@android.com>
	<4CEB77E0.10202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CEB77E0.10202-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 23, 2010 at 12:14 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 12:06, Colin Cross wrote:
>> The synchronize_rcu call in cgroup_attach_task can be very
>> expensive. =A0All fastpath accesses to task->cgroups that expect
>> task->cgroups not to change already use task_lock() or
>> cgroup_lock() to protect against updates, and, in cgroup.c,
>> only the CGROUP_DEBUG files have RCU read-side critical
>> sections.
>>
>> sched.c uses RCU read-side-critical sections on task->cgroups,
>> but only to ensure that a dereference of task->cgroups does
>> not become invalid, not that it doesn't change.
>>
>
> Other cgroup subsystems also use rcu_read_lock to access task->cgroups,
> for example net_cls cgroup and device cgroup.
I believe the same comment applies as sched.c, I'll update the commit messa=
ge.

> I don't think the performance of task attaching is so critically
> important that we have to use call_rcu() instead of synchronize_rcu()?
On my desktop, moving a task between cgroups averages 100 ms, and on
an Tegra2 SMP ARM platform it takes 20 ms.  Moving a task with many
threads can take hundreds of milliseconds or more.  With this patch it
takes 50 microseconds to move one task, a 400x improvement.

>> This patch adds a function put_css_set_rcu, which delays the
>> put until after a grace period has elapsed. =A0This ensures that
>> any RCU read-side critical sections that dereferenced
>> task->cgroups in sched.c have completed before the css_set is
>> deleted. =A0The synchronize_rcu()/put_css_set() combo in
>> cgroup_attach_task() can then be replaced with
>> put_css_set_rcu().
>>
>
>> Also converts the CGROUP_DEBUG files that access
>> current->cgroups to use task_lock(current) instead of
>> rcu_read_lock().
>>
>
> What for? What do we gain from doing this for those debug
> interfaces?
Left over from the previous patch that incorrectly dropped RCU
completely.  I'll put the rcu_read_locks back.

>> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
>>
>> ---
>>
>> This version fixes the problems with the previous patch by
>> keeping the use of RCU in cgroup_attach_task, but allowing
>> cgroup_attach_task to return immediately by deferring the
>> final put_css_reg to an rcu callback.
>>
>> =A0include/linux/cgroup.h | =A0 =A04 +++
>> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 58 +++++++++++++++++++++++++++++=
+++++++++----------
>> =A02 files changed, 50 insertions(+), 12 deletions(-)
>
