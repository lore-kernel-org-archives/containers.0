From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/5] mnt: Only change user settable mount flags in
	remount
Date: Thu, 31 Jul 2014 17:10:15 -0700
Message-ID: <87vbqdcbo8.fsf@x220.int.ebiederm.org>
References: <20140724194920.GU26600@ubuntumail>
	<CAOP=4wh-AXf7qPy0rPaQ6RFbbJGRWKo0h1Rn=9vLUeJ6b6Q7YA@mail.gmail.com>
	<8738dqh2j1.fsf@x220.int.ebiederm.org> <20140725060810.GC31313@1wt.eu>
	<877g2xou2u.fsf@x220.int.ebiederm.org>
	<87r415nf3k.fsf_-_@x220.int.ebiederm.org>
	<874my1neyr.fsf_-_@x220.int.ebiederm.org>
	<CAOP=4wj7m+w4aDJCuQaf3r9aFraPN1SvPgFSz=_UNkyC8gEHyQ@mail.gmail.com>
	<87ppgnjyx4.fsf_-_@x220.int.ebiederm.org>
	<87ha1zjyf0.fsf_-_@x220.int.ebiederm.org>
	<20140731231354.GE7954@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140731231354.GE7954@ubuntumail> (Serge Hallyn's message of
	"Thu, 31 Jul 2014 23:13:54 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Lutomirski <andy-RHosVwM/Cj8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Willy Tarreau <w@1wt.eu>, security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> 
>> Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org> discovered that by remounting a
>> read-only bind mount read-only in a user namespace the
>> MNT_LOCK_READONLY bit would be cleared, allowing an unprivileged user
>> to the remount a read-only mount read-write.
>> 
>> Correct this by replacing the mask of mount flags to preserve
>> with a mask of mount flags that may be changed, and preserve
>> all others.   This ensures that any future bugs with this mask and
>> remount will fail in an easy to detect way where new mount flags
>> simply won't change.
>> 
>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> Not exactly sure about the name.  Actually seems like it should be
> caled MNT_USER_UNCLEARABLE_MASK or something, but

It is the set of mnt_flags that user space can cause to change.
So this patch inverts that mask and unconditionally preserves
everything else.

> Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
>
>> ---
>>  fs/namespace.c        | 2 +-
>>  include/linux/mount.h | 4 +++-
>>  2 files changed, 4 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index 7187d01329c3..cb40449ea0df 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -1937,7 +1937,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
>>  		err = do_remount_sb(sb, flags, data, 0);
>>  	if (!err) {
>>  		lock_mount_hash();
>> -		mnt_flags |= mnt->mnt.mnt_flags & MNT_PROPAGATION_MASK;
>> +		mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
>>  		mnt->mnt.mnt_flags = mnt_flags;
>>  		touch_mnt_namespace(mnt->mnt_ns);
>>  		unlock_mount_hash();
>> diff --git a/include/linux/mount.h b/include/linux/mount.h
>> index 839bac270904..b637a89e1fae 100644
>> --- a/include/linux/mount.h
>> +++ b/include/linux/mount.h
>> @@ -42,7 +42,9 @@ struct mnt_namespace;
>>   * flag, consider how it interacts with shared mounts.
>>   */
>>  #define MNT_SHARED_MASK	(MNT_UNBINDABLE)
>> -#define MNT_PROPAGATION_MASK	(MNT_SHARED | MNT_UNBINDABLE)
>> +#define MNT_USER_SETTABLE_MASK  (MNT_NOSUID | MNT_NODEV | MNT_NOEXEC \
>> +				 | MNT_NOATIME | MNT_NODIRATIME | MNT_RELATIME \
>> +				 | MNT_READONLY)
>>  
>>  #define MNT_INTERNAL_FLAGS (MNT_SHARED | MNT_WRITE_HOLD | MNT_INTERNAL | \
>>  			    MNT_DOOMED | MNT_SYNC_UMOUNT | MNT_MARKED)
>> -- 
>> 1.9.1
>> 
