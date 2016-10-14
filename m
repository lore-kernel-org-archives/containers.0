From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] mount: In mark_umount_candidates and
	__propogate_umount visit each mount once
Date: Thu, 13 Oct 2016 21:45:00 -0500
Message-ID: <87wphb4pjn.fsf@x220.int.ebiederm.org>
References: <1476141965-21429-1-git-send-email-avagin@openvz.org>
	<877f9c6ui8.fsf@x220.int.ebiederm.org>
	<87pon458l1.fsf_-_@x220.int.ebiederm.org>
	<20161013214650.GB19836@outlook.office365.com>
	<CANaxB-xPkgdyeg0z6TvExMfyy4uOC+Nu4Q99WpCscNKMWz8VPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CANaxB-xPkgdyeg0z6TvExMfyy4uOC+Nu4Q99WpCscNKMWz8VPg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andrey Vagin's message of "Thu, 13 Oct 2016 19:31:22 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> On Thu, Oct 13, 2016 at 2:46 PM, Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> wrote:
>> On Thu, Oct 13, 2016 at 02:53:46PM -0500, Eric W. Biederman wrote:
>>>
>>> Adrei Vagin pointed out that time to executue propagate_umount can go
>>> non-linear (and take a ludicrious amount of time) when the mount
>>> propogation trees of the mounts to be unmunted by a lazy unmount
>>> overlap.
>>>
>>> Solve this in the most straight forward way possible, by adding a new
>>> mount flag to mark parts of the mount propagation tree that have been
>>> visited, and use that mark to skip parts of the mount propagation tree
>>> that have already been visited during an unmount.  This guarantees
>>> that each mountpoint in the possibly overlapping mount propagation
>>> trees will be visited exactly once.
>>>
>>> Add the functions propagation_visit_next and propagation_revisit_next
>>> to coordinate setting and clearling the visited mount mark.
>>>
>>> Here is a script to generate such mount tree:
>>> $ cat run.sh
>>> mount -t tmpfs test-mount /mnt
>>> mount --make-shared /mnt
>>> for i in `seq $1`; do
>>>         mkdir /mnt/test.$i
>>>         mount --bind /mnt /mnt/test.$i
>>> done
>>> cat /proc/mounts | grep test-mount | wc -l
>>> time umount -l /mnt
>>> $ for i in `seq 10 16`; do echo $i; unshare -Urm bash ./run.sh $i; done
>>>
>>> Here are the performance numbers with and without the patch:
>>>
>>> mounts | before | after (real sec)
>>> -----------------------------
>>>   1024 |  0.071 | 0.024
>>>   2048 |  0.184 | 0.030
>>>   4096 |  0.604 | 0.040
>>>   8912 |  4.471 | 0.043
>>>  16384 | 34.826 | 0.082
>>>  32768 |        | 0.151
>>>  65536 |        | 0.289
>>> 131072 |        | 0.659
>>>
>>> Andrei Vagin fixing this performance problem is part of the
>>> work to fix CVE-2016-6213.
>>>
>>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> Reported-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>> ---
>>>
>>> Andrei can you take a look at this patch and see if you can see any
>>> problems.  My limited testing suggests this approach does a much better
>>> job of solving the problem you were seeing.  With the time looking
>>> almost linear in the number of mounts now.
>>
>> I read this patch and I like the idea.
>>
>> Then I run my tests and one of them doesn't work with this patch.
>> I haven't found a reason yet.
>
>>> +     for (m = propagation_visit_next(parent, parent); m;
>>> +                     m = propagation_visit_next(m, parent)) {
>>>               struct mount *child = __lookup_mnt_last(&m->mnt,
>>>                                               mnt->mnt_mountpoint);
>
> The reason is that this loop is called for different "mnt", but
> it is executed only once with this optimization.
>
> So I think the idea to mark parent will not work, because one parent
> can have a few children which have to be umounted.

Good catch.  So what needs to be marked is the parent mount and
mountpoint combination.  Which is effectively the child mount.

I still think replacing the propagation_next and fixing the propagation
walk is the way to go.   But it sounds like to make things work the
__lookup_mnt_last needs to be moved into the propagation walk function.

That doesn't feel to hard.  I will have to see what the code looks like.

Eric
