From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/9] [RFC] Support named cgroups hierarchies
Date: Wed, 1 Jul 2009 19:49:48 -0700
Message-ID: <6599ad830907011949h13598e36m45b85ae76900b90a@mail.gmail.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021057.14469.37548.stgit@menage.mtv.corp.google.com>
	<20090702112814.ddf0c280.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702112814.ddf0c280.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 1, 2009 at 7:28 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>> Open issues:
>>
>> - should the specification be via a name=3D option as in this patch, or
>> =A0 should we simply use the "device name" as passed to the mount()
>> =A0 system call? =A0Using the device name is more conceptually clean and
>> =A0 consistent with the filesystem API; however, given that the device
>> =A0 name is currently ignored by cgroups, this would lead to a
>> =A0 user-visible behaviour change.
>>
>
> IMHO, name=3D option is good because people think device name for pseudo =
file
> system has no meanings. I think just leaving it as "no meaning" is better.
>

Yes, I guess that makes sense. That was Li Zefan's opinion too.

>>
>> +#define MAX_CGROUP_ROOT_NAMELEN 64
>> +
>
> I don't like long names but....isn't this too short ? How about NAME_MAX ?
>


>
>> =A0/*
>> =A0 * A cgroupfs_root represents the root of a cgroup hierarchy,
>> =A0 * and may be associated with a superblock to form an active
>> @@ -93,6 +95,9 @@ struct cgroupfs_root {
>>
>> =A0 =A0 =A0 /* The path to use for release notifications. */
>> =A0 =A0 =A0 char release_agent_path[PATH_MAX];
>> +
>> + =A0 =A0 /* The name for this hierarchy - may be empty */
>> + =A0 =A0 char name[MAX_CGROUP_ROOT_NAMELEN];
>> =A0};
>>
> If you don't want to make cgroupfs_root bigger,
>
> =A0 =A0 =A0 =A0cgroupfs_root {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0......
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* this must be the bottom of struct */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0char name[0];
> =A0 =A0 =A0 =A0}
>
> Is a choice.

I'd rather avoid something like that since I think it's less readable
- I'd probably just make the name into a pointer in that case.

>
> BTW, reading a patch, any kind of charactors are allowed ?

Yes, other than \000 of course. I guess maybe I should use
seq_escape() to print the name to avoid confusion in the event that
people put whitespace in there, or else just ban whitespace (or maybe
all non-alphanumeric chars).

Paul
