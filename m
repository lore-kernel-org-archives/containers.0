From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Wed, 01 Aug 2007 03:22:40 -0600
Message-ID: <m1fy33pq1r.fsf@ebiederm.dsl.xmission.com>
References: <m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>
	<46AF15F6.6010202@suse.de> <m11weorf3l.fsf@ebiederm.dsl.xmission.com>
	<46AF1E57.3030209@suse.de> <20070731141613.GC13674@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070731141613.GC13674-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org> (Tejun Heo's message of
	"Tue, 31 Jul 2007 23:16:13 +0900")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Tue, Jul 31, 2007 at 08:34:47PM +0900, Tejun Heo wrote:
>> > If sysfs_mutex nested the other way things would be easier,
>> > and we could grab all of the i_mutexes we wanted.  I wonder if we can
>> > be annoying in sysfs_lookup and treat that as the lock inversion
>> > case using mutex_trylock etc.  And have sysfs_mutex be on the
>> > outside for the rest of the cases?
>> 
>> The problem with treating sysfs_lookup as inversion case is that vfs
>> layer grabs i_mutex outside of sysfs_lookup.  Releasing i_mutex from
>> inside sysfs_lookup would be a hacky layering violation.
>> 
>> Then again, the clean up which can come from the new sysfs_looukp_dentry
>> is very significant.  I'll think about it a bit more.
>
> How about something like this?  __sysfs_get_dentry() never creates any
> dentry, it just looks up existing ones.  sysfs_get_dentry() calls
> __sysfs_get_dentry() and if it fails, it builds a path string and look
> up using regular vfs_path_lookup().  Once in the creation path,
> sysfs_get_dentry() is allowed to fail, so allocating path buf is fine.
>
> It still needs to retry when vfs_path_lookup() returns -ENOENT or the
> wrong dentry but things are much simpler now.  It doesn't violate any
> VFS locking rule while maintaining all the benefits of
> sysfs_get_dentry() cleanup.
>
> Something like LOOKUP_KERNEL is needed to ignore security checks;
> otherwise, we'll need to resurrect lookup_one_len_kern() and open code
> look up.
>
> The patch is on top of all your patches and is in barely working form.

I will look a little more and see.  But right now it looks like the
real problem with locking is that we use sysfs_mutex to lock the
sysfs_dirent s_children list.

Instead it really looks like we should use i_mutex from the appropriate
inode.  Or is there a real performance problem with forcing the directory
inodes in core when we modify the directories?

Using i_mutex to lock the s_children list. Allows us to make sysfs_mutex
come before i_mutex, and it removes the need for an additional lock in
sysfs_lookup.  So generally it looks like the right thing to do and
it should noticeably simplify the sysfs locking.

Was this an oversight or is there some good reason we aren't using
i_mutex to lock the s_children list?

Eric
