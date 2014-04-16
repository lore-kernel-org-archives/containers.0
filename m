From: Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup: implement cgroup.subtree_populated for the
	default hierarchy
Date: Tue, 15 Apr 2014 21:15:10 -0700
Message-ID: <CAPXgP11YtrVan7DLQSM0i_PQPdTDT84JqJ6BgAo_rtdMwKZTAw@mail.gmail.com>
References: <1397511846-2904-1-git-send-email-tj@kernel.org>
	<1397511846-2904-4-git-send-email-tj@kernel.org>
	<534DEF62.4090900@huawei.com>
	<CAPXgP12kvPdX0QExwN2JphDfEW=d+7K2c_Y8DbomGd=YVy=VGQ@mail.gmail.com>
	<87tx9uhr0j.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tx9uhr0j.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 15, 2014 at 8:50 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Kay Sievers <kay-tD+1rO4QERM@public.gmane.org> writes:
>
>> On Tue, Apr 15, 2014 at 7:48 PM, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
>>> On 2014/4/15 5:44, Tejun Heo wrote:
>>>> cgroup users often need a way to determine when a cgroup's
>>>> subhierarchy becomes empty so that it can be cleaned up.  cgroup
>>>> currently provides release_agent for it; unfortunately, this mechanism
>>>> is riddled with issues.
>>>>
>>>> * It delivers events by forking and execing a userland binary
>>>>   specified as the release_agent.  This is a long deprecated method of
>>>>   notification delivery.  It's extremely heavy, slow and cumbersome to
>>>>   integrate with larger infrastructure.
>>>>
>>>> * There is single monitoring point at the root.  There's no way to
>>>>   delegate management of subtree.
>>>>
>>>> * The event isn't recursive.  It triggers when a cgroup doesn't have
>>>>   any tasks or child cgroups.  Events for internal nodes trigger only
>>>>   after all children are removed.  This again makes it impossible to
>>>>   delegate management of subtree.
>>>>
>>>> * Events are filtered from the kernel side.  "notify_on_release" file
>>>>   is used to subscribe to or suppress release event.  This is
>>>>   unnecessarily complicated and probably done this way because event
>>>>   delivery itself was expensive.
>>>>
>>>> This patch implements interface file "cgroup.subtree_populated" which
>>>> can be used to monitor whether the cgroup's subhierarchy has tasks in
>>>> it or not.  Its value is 0 if there is no task in the cgroup and its
>>>> descendants; otherwise, 1, and kernfs_notify() notificaiton is
>>>> triggers when the value changes, which can be monitored through poll
>>>> and [di]notify.
>>>>
>>>
>>> For the old notification mechanism, the path of the cgroup that becomes
>>> empty will be passed to the user specified release agent. Like this:
>>>
>>> # cat /sbin/cpuset_release_agent
>>> #!/bin/sh
>>> rmdir /dev/cpuset/$1
>>>
>>> How do we achieve this using inotify?
>>>
>>> - monitor all the cgroups, or
>>> - monitor all the leaf cgroups, and travel cgrp->parent to delete all
>>>   empty cgroups.
>>> - monitor root cgroup only, and travel the whole hierarchy to find
>>>   empy cgroups when it gets an fs event.
>>>
>>> Seems none of them is scalible.
>>
>> The manager would add all cgroups as watches to one inotify file
>> descriptor, it should not be problem to do that.
>
> inotify won't work on cgroupfs.

Inotify on kernfs will work.

Kay
