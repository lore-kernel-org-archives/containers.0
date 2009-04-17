From: =?ISO-8859-1?Q?Fernando_Luis_V=E1zquez_Cao?=
 <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Fri, 17 Apr 2009 20:35:17 +0900
Message-ID: <49E86975.1030200__47601.9944683232$1239968432$gmane$org@oss.ntt.co.jp>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-2-git-send-email-righi.andrea@gmail.com>
	<20090417102417.88a0ef93.kamezawa.hiroyu@jp.fujitsu.com>
	<49E7E1CF.6060209@cn.fujitsu.com> <20090417102539.GA16838@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090417102539.GA16838@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrea Righi wrote:
> On Fri, Apr 17, 2009 at 09:56:31AM +0800, Li Zefan wrote:
>> KAMEZAWA Hiroyuki wrote:
>>> On Tue, 14 Apr 2009 22:21:12 +0200
>>> Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>
>>>> +Example:
>>>> +* Create an association between an io-throttle group and a bio-cgroup group
>>>> +  with "bio" and "blockio" subsystems mounted in different mount points:
>>>> +  # mount -t cgroup -o bio bio-cgroup /mnt/bio-cgroup/
>>>> +  # cd /mnt/bio-cgroup/
>>>> +  # mkdir bio-grp
>>>> +  # cat bio-grp/bio.id
>>>> +  1
>>>> +  # mount -t cgroup -o blockio blockio /mnt/io-throttle
>>>> +  # cd /mnt/io-throttle
>>>> +  # mkdir foo
>>>> +  # echo 1 > foo/blockio.bio_id
>>> Why do we need multiple cgroups at once to track I/O ?
>>> Seems complicated to me.
>>>
>> IIUC, it also disallows other subsystems to be binded with blockio subsys:
>>   # mount -t cgroup -o blockio cpuset xxx /mnt
>>   (failed)
>>
>> and if a task is moved from cg1(id=1) to cg2(id=2) in bio subsys, this task
>> will be moved from CG1(id=1) to CG2(id=2) automatically in blockio subsys.
>>
>> All these are odd, unexpected, complex and bug-prone I think..
> 
> Implementing bio-cgroup functionality as pure infrastructure framework
> instead of a cgroup subsystem would remove all this oddity and
> complexity.

Andrea, I agree with you completely. In fact, we have been working on that for
a while and have just proposed doing exactly that on a different mail thread
(you are CC'ed). It would be great if you could comment on that proposal.

Thanks,

Fernando

> For example, the actual functionality that I need for the io-throttle
> controller is just an interface to set and get the cgroup owner of a
> page. I think it should be the same also for other potential users of
> bio-cgroup.
> 
> So, what about implementing the bio-cgroup functionality as cgroup "page
> tracking" infrastructure and provide the following interfaces:
> 
> /*
>  * Encode the cgrp->css.id in page_group->flags
>  */
> void set_cgroup_page_owner(struct page *page, struct cgroup *cgrp);
> 
> /*
>  * Returns the cgroup owner of a page, decoding the cgroup id from
>  * page_cgroup->flags.
>  */
> struct cgroup *get_cgroup_page_owner(struct page *page);
> 
> This also wouldn't increase the size of page_cgroup because we can
> encode the cgroup id in the unused bits of page_cgroup->flags, as
> originally suggested by Kame.
> 
> And I think it could be used also by dm-ioband, even if it's not a
> cgroup-based subsystem... but I may be wrong. Ryo what's your opinion?
> 
> -Andrea
