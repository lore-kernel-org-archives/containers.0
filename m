From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 6/6] vfs: Cache the results of path_connected
Date: Tue, 04 Aug 2015 12:41:32 -0500
Message-ID: <871tfj0x4j.fsf@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<8738009i0h.fsf_-_@x220.int.ebiederm.org>
	<20150804115215.GA317@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150804115215.GA317-wo1vFcy6AUs@public.gmane.org> (Andrew Vagin's message of "Tue,
	4 Aug 2015 14:52:17 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Andrew Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Mon, Aug 03, 2015 at 04:30:54PM -0500, Eric W. Biederman wrote:
>> 
>> Add a new field mnt_escape_count in nameidata, initialize it to 0 and
>> cache the value of read_mnt_escape_count in nd->mnt_escape_count.
>> 
>> This allows a single check in path_connected in the common case where
>> either the mount has had no escapes (mnt_escape_count == 0) or there
>> has been an escape and it has been validated that the current path
>> does not escape.
>> 
>> To keep the cache valid nd->mnt_escape_count must be set to 0 whenever
>> the nd->path.mnt changes or when nd->path.dentry changes such that
>> the connectedness of the previous value of nd->path.dentry does
>> not imply the connected of the new value of nd->path.dentry.
>> 
>> Various locations in fs/namei.c are updated to set
>> nd->mnt_escape_count to 0 as necessary.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  fs/namei.c | 26 +++++++++++++++++++++++---
>>  1 file changed, 23 insertions(+), 3 deletions(-)
>> 
>> diff --git a/fs/namei.c b/fs/namei.c
>> index bccd3810ff60..79a5dca073f5 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -514,6 +514,7 @@ struct nameidata {
>>  	struct nameidata *saved;
>>  	unsigned	root_seq;
>>  	int		dfd;
>> +	unsigned	mnt_escape_count;
>>  };
>>  
>>  static void set_nameidata(struct nameidata *p, int dfd, struct filename *name)
>> @@ -572,12 +573,13 @@ static bool path_connected(struct nameidata *nd)
>>  	struct vfsmount *mnt = nd->path.mnt;
>>  	unsigned escape_count = read_mnt_escape_count(mnt);
>>  
>> -	if (likely(escape_count == 0))
>> +	if (likely(escape_count == nd->mnt_escape_count))
>>  		return true;
>
> The size of mnt_escape_count is only 4 bytes. Looks like it possible to
> make UINT_MAX / 2 operations for the resonable time and get the same
> value of mnt_escape_count, path_connected() will return true, but the
> path may be already detached. What do you think about this?

It is an interesting question.  

For the locking on rename we have something that looks like:
mutex_lock(&...s_vfs_mutex);
mutex_lock(&p2->d_inode->i_mutex);
mutex_lock(&p1->d_inode->i_mutex);
read_seqlock_excl(&mount_lock);
escape_count++;
write_seqlock(&rename_lock);
write_seqcount_begin(&dentry->d_seq);
write_seqcount_begin_nested(&target->d_seq);
write_seqcount_end_nested(&target->d_seq);
write_seqcount_end(&dentry->d_seq);
write_sequnlock(&rename_lock);
escape_count++;
read_sequnlock_excl(&mount_lock);
mutex_unlock(&p1->d_inode->i_mutex);
mutex_unlock(&p2->d_inode->i_mutex);
mutex_unlock(&...s_vfs_mutex);

Which is at least 16 serialized cpu operations.  To reach overflow then
it would take at least 16 * 2**32 operations cpu operations.  On a 4Ghz
16 * 2**32 operations would take roughly 16 seconds.  In practice I
think it would take noticably more than 16 seconds to perform that many
renames as there is a lot more going on than just the locking I signled
out.

A pathname lookup taking 16 seconds seems absurd.  But perhaps in the
worst case.

The maximum length of a path that can be passed into path_lookup is
4096.  For a lookup to be problematic there must be at least as many
instances of .. as there are of any other path component.  So each pair
of a minium length path element and a .. element must take at least 5
bytes. Which in 4096 bytes leaves room for 819 path elements.  If every
one of those 819 path components triggered a disk seek at 100 seeks per
second I could see a path name lookup potentially taking 8 seconds.

MAXSYMLINKS is 40.  So you could perhaps if you have a truly pathlogical
set of file names might make that 320 seconds. Ick.


To get some real figures I have performed a few renames on my 2.5Ghz
laptop with ext4 on an ssd.  Performing a simple rename in the same
directory (which involves much less than in required to rename a file
out of a mount point) I get the following timings:

   renames    time
   200,000      1.2s
 2,000,000     17.2s
20,000,000    205.6s
40,000,000    418.5s

At that kind of speed I would expect 4,000,000,000 renames to take 41850
seconds or 11.625 hours.

Going the other way on an old system with spinning rust for a hard drive
I created 1000 nested directories all named a and times how long it
would take to stat a pathlogical pathname.  With a simple pathname
without symlinks involved the worst case I have been able to trigger
is a 0.3 second path name lookup time.   Not being satisified with
that I managed to create a file about 83,968 directories deep and a
set of 40 symlinks setup up to get me there in one stat call the first
symlink being 8192 directories deep.  The worst case time I have been
able to measure from stat -L on the symlink that leads me to that file
is 14.5 seconds. 

If my numbers are at all representative I don't see a realistic
possibility of being able to perform enough renames to roll over a 32bit
mnt_escape_count during a path name lookup.  Even my most optimistic
estimate required 16 seconds to perform the renames and I have not been
able to get any pathname lookup to run that long.

At the same time I do think it is probably worth it to make escape count
an unsigned long, because that is practically free and it removes the
any theoretical concern on 64bit.

Am I missing anything?

Eric
