From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH v2] mount: In mark_umount_candidates and
	__propogate_umount visit each mount once
Date: Tue, 18 Oct 2016 01:49:52 -0500
Message-ID: <87r37e9mnj.fsf@xmission.com>
References: <1476141965-21429-1-git-send-email-avagin@openvz.org>
	<877f9c6ui8.fsf@x220.int.ebiederm.org>
	<87pon458l1.fsf_-_@x220.int.ebiederm.org>
	<20161013214650.GB19836@outlook.office365.com>
	<CANaxB-xPkgdyeg0z6TvExMfyy4uOC+Nu4Q99WpCscNKMWz8VPg@mail.gmail.com>
	<87wphb4pjn.fsf@x220.int.ebiederm.org>
	<8737jy3htt.fsf_-_@x220.int.ebiederm.org>
	<20161018024000.GA4901@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161018024000.GA4901-1ViLX0X+lBJGNQ1M2rI3KwRV3xvJKrda@public.gmane.org> (Andrei Vagin's
	message of "Mon, 17 Oct 2016 19:40:01 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:

> On Fri, Oct 14, 2016 at 01:29:18PM -0500, Eric W. Biederman wrote:
>> 
>> Adrei Vagin pointed out that time to executue propagate_umount can go
>> non-linear (and take a ludicrious amount of time) when the mount
>> propogation trees of the mounts to be unmunted by a lazy unmount
>> overlap.
>> 
>> Solve this in the most straight forward way possible, by adding a new
>> mount flag to mark parts of the mount propagation tree that have been
>> visited, and use that mark to skip parts of the mount propagation tree
>> that have already been visited during an unmount.  This guarantees
>> that each mountpoint in the possibly overlapping mount propagation
>> trees will be visited exactly once.
>> 
>> Add the functions propagation_visit_next and propagation_revisit_next
>> to coordinate setting and clearling the visited mount mark.
>> 
>> The skipping of already unmounted mounts has been moved from
>> __lookup_mnt_last to mark_umount_candidates, so that the new
>> propagation functions can notice record when the propagation tree
>> passes through the initial set of unmounted mounts.  Except in
>> umount_tree as part of the unmounting process the only place where
>> unmounted mounts should be found are in unmounted subtrees.  All of
>> the other callers of __lookup_mnt_last are from mounted subtrees so
>> the not checking for unmounted mounts should not affect them.
>> 
>> Here is a script to generate such mount tree:
>> $ cat run.sh
>> mount -t tmpfs test-mount /mnt
>> mount --make-shared /mnt
>> for i in `seq $1`; do
>>         mkdir /mnt/test.$i
>>         mount --bind /mnt /mnt/test.$i
>> done
>> cat /proc/mounts | grep test-mount | wc -l
>> time umount -l /mnt
>> $ for i in `seq 10 16`; do echo $i; unshare -Urm bash ./run.sh $i; done
>> 
>> Here are the performance numbers with and without the patch:
>> 
>> mhash  |  8192   |  8192  |  8192       | 131072 | 131072      | 104857 | 104857
>> mounts | before  | after  | after (sys) | after  | after (sys) |  after | after (sys)
>> -------------------------------------------------------------------------------------
>>   1024 |  0.071s | 0.023s | 0.008s      | 0.026s | 0.000s      | 0.024s | 0.008s
>>   2048 |  0.184s | 0.030s | 0.012s      | 0.035s | 0.008s      | 0.030s | 0.012s
>>   4096 |  0.604s | 0.047s | 0.012s      | 0.042s | 0.016s      | 0.032s | 0.016s
>>   8912 |  4.471s | 0.085s | 0.020s      | 0.059s | 0.059s      | 0.050s | 0.036s
>>  16384 | 34.826s | 0.105s | 0.092s      | 0.109s | 0.060s      | 0.087s | 0.068s
>>  32768 |         | 0.245s | 0.168s      | 0.192s | 0.144s      | 0.167s | 0.156s
>>  65536 |         | 0.833s | 0.716s      | 0.485s | 0.276s      | 0.468s | 0.316s
>> 131072 |         | 4.628s | 4.108s      | 0.758s | 0.632s      | 0.736s | 0.612s
>> 
>> Andrei Vagin reports fixing this performance problem is part of the
>> work to fix CVE-2016-6213.
>> 
>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Reported-by: Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>> 
>> I think this version is very close.  I had to modify __lookup_mnt_last
>> to not skip MOUNT_UMOUNT or we would never see when the mount
>> propagation trees intersected.
>> 
>> This doesn't look as good as the previous buggy version but it looks
>> good.  When the hash table isn't getting full the times look pretty
>> linear.  So it may be necessary to do some hash table resizing.
>> 
>> That said there remains one issue I need to think about some more.
>> 
>> In mark_umount_candidates I don't mark mounts that are locked to their
>> parent and their parent is not marked as a umount candidate.  Given that
>> we skip processing mounts multiple times this might result in a mount
>> whose parent gets marked as unmountable after the first time we see a
>> mount not getting marked as unmountable later.

Unfortunately my fears are born out as demonstrated by the script
below.
    $ cat pathology.sh
    #!/bin/sh
    set -e
    set -x
    
    mount -t tmpfs base /mnt
    mount --make-shared /mnt
    mkdir -p /mnt/b
    
    mount -t tmpfs test1 /mnt/b
    mount --make-shared /mnt/b
    mkdir -p /mnt/b/10
    
    mount -t tmpfs test2 /mnt/b/10
    mount --make-shared /mnt/b/10
    mkdir -p /mnt/b/10/20
    
    mount --rbind /mnt/b /mnt/b/10/20
    
    cat /proc/self/mountinfo
    ls /mnt /mnt/b /mnt/b/10  /mnt/b/10/20  /mnt/b/10/20/10  /mnt/b/10/20/10/20 || true
    
    unshare -Urm --propagation unchanged /bin/bash -c 'cat /proc/self/mountinfo; sleep 5; ls /mnt /mnt/b /mnt/b/10 /mnt/b/10/20 /mnt/b/10/20/10 \
    /mnt/b/10/20/10/20 || true; cat /proc/self/mountinfo' &
    sleep 1
    umount -l /mnt/b/
    wait %%
    $ unshare -Urm ./pathology.sh


>> Anyway Andrei if you could check this out and see if you can see
>> anything I missed please let me know.
>
> I've tested this patch today and it works to me. The idea of this patch
> looks good for me too. Thanks! There is one inline comment.

It is definitely close but there is an ordering problem (see above)
that needs some more attention.  I have just finished building
myself a reproducer and am going to go sleep on i.

The little script above demonstrates that the locked mount handling
(of preventing umounts) is too conservative today, and is even worse
with these changes.

Even worse locked mounts are unnecessary to fail to unmount everything,
with a single pass through the propagation tree.  My script above
demonstrates one such topology where there will be problems.

Now that bug already exists today so I don't expect this change makes
anything practically worse.  But I would really like to know if it is
possible to do better before we merge this change.

>>  fs/namespace.c        |   6 +--
>>  fs/pnode.c            | 147 ++++++++++++++++++++++++++++++++++++++++++++------
>>  fs/pnode.h            |   4 ++
>>  include/linux/mount.h |   2 +
>>  4 files changed, 138 insertions(+), 21 deletions(-)
>> 
>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index db1b5a38864e..1ca99fa2e0f4 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -650,13 +650,11 @@ struct mount *__lookup_mnt_last(struct vfsmount *mnt, struct dentry *dentry)
>>  	p = __lookup_mnt(mnt, dentry);
>>  	if (!p)
>>  		goto out;
>> -	if (!(p->mnt.mnt_flags & MNT_UMOUNT))
>> -		res = p;
>> +	res = p;
>>  	hlist_for_each_entry_continue(p, mnt_hash) {
>>  		if (&p->mnt_parent->mnt != mnt || p->mnt_mountpoint != dentry)
>>  			break;
>> -		if (!(p->mnt.mnt_flags & MNT_UMOUNT))
>> -			res = p;
>
> __lookup_mnt_last is used in propagate_mount_busy and
> attach_recursive_mnt. Should we do smth to save old
> behaviour of these functions.

Reasonable question. I am actually reverting __lookup_mnt_last to a
fairly recent behavior.   I added the MNT_UMOUNT test when I started
leaving things in the hash table to keep lazy unmounts from having a
information disclosure issue.

Mounts with MNT_UMOUNT will only be seen connected to mounted mounts
during propogate_umount.  attach_recursive_mounts has no chance of
seeing that condition, and propagate_mount_busy is called before
mount_umount. Similary propagate_umount_lock is also called before any
mounts get into a visible halfway unmounted state.

So no.  I don't see any reason to preseve the extra MNT_UMOUNT test.

Eric
