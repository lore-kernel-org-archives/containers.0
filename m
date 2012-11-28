From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix lockdep warning for event_control
Date: Wed, 28 Nov 2012 13:33:11 -0800
Message-ID: <xr93hao9ifag.fsf__18274.9164909639$1354138413$gmane$org@gthelen.mtv.corp.google.com>
References: <1354133742-22175-1-git-send-email-gthelen@google.com>
	<20121128210719.GB24683@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121128210719.GB24683-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org> (Tejun Heo's message of
	"Wed, 28 Nov 2012 13:07:19 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Aaron Durbin <adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 28 2012, Tejun Heo wrote:

> Hello, Greg.
>
> On Wed, Nov 28, 2012 at 12:15:42PM -0800, Greg Thelen wrote:
>> @@ -4276,6 +4276,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
>>  	DEFINE_WAIT(wait);
>>  	struct cgroup_event *event, *tmp;
>>  	struct cgroup_subsys *ss;
>> +	struct list_head tmp_list;
>
> LIST_HEAD(tmp_list);
>
>>  
>>  	lockdep_assert_held(&d->d_inode->i_mutex);
>>  	lockdep_assert_held(&cgroup_mutex);
>> @@ -4330,16 +4331,20 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
>>  	/*
>>  	 * Unregister events and notify userspace.
>>  	 * Notify userspace about cgroup removing only after rmdir of cgroup
>> -	 * directory to avoid race between userspace and kernelspace
>> +	 * directory to avoid race between userspace and kernelspace. Use
>> +	 * a temporary list to avoid a deadlock with cgroup_event_wake(). Since
>> +	 * cgroup_event_wake() is called with the wait queue head locked,
>> +	 * remove_wait_queue() cannot be called while holding event_list_lock.
>>  	 */
>>  	spin_lock(&cgrp->event_list_lock);
>> -	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
>> +	list_replace_init(&cgrp->event_list, &tmp_list);
>
> list_splice_init();
>
> would be more conventional, I think.

I used list_replace_init() because it avoided unnecessary init of
tmp_list.  But I have no objection to list_splice_init().  I'll repost
with list_splice_init().

>> +	spin_unlock(&cgrp->event_list_lock);
>> +	list_for_each_entry_safe(event, tmp, &tmp_list, list) {
>>  		list_del(&event->list);
>
> Maybe convert this to list_del_init() while at it?

I assume this isn't technically required, but defensive.  Seems like we
should also convert the list_del(&event->list) in cgroup_event_wake()
for consistency.  I'll send these in separate patch.

>>  		remove_wait_queue(event->wqh, &event->wait);
>>  		eventfd_signal(event->eventfd, 1);
>>  		schedule_work(&event->remove);
>>  	}
>> -	spin_unlock(&cgrp->event_list_lock);
>
> Thanks.
