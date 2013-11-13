From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/2] userns: Better restrictions on when proc
	and sysfs can be mounted
Date: Wed, 13 Nov 2013 15:26:19 +0800
Message-ID: <5283299B.8080702@cn.fujitsu.com>
References: <878uzmhkqg.fsf@xmission.com>
	<52749663.2000701@cn.fujitsu.com>	<527C4D88.10907@cn.fujitsu.com>
	<87k3gigmgj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3gigmgj.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/09/2013 01:42 PM, Eric W. Biederman wrote:
> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
>> On 11/02/2013 02:06 PM, Gao feng wrote:
>>> Hi Eric,
>>>
>>> On 08/28/2013 05:44 AM, Eric W. Biederman wrote:
>>>>
>>>> Rely on the fact that another flavor of the filesystem is already
>>>> mounted and do not rely on state in the user namespace.
>>>>
>>>> Verify that the mounted filesystem is not covered in any significant
>>>> way.  I would love to verify that the previously mounted filesystem
>>>> has no mounts on top but there are at least the directories
>>>> /proc/sys/fs/binfmt_misc and /sys/fs/cgroup/ that exist explicitly
>>>> for other filesystems to mount on top of.
>>>>
>>>> Refactor the test into a function named fs_fully_visible and call that
>>>> function from the mount routines of proc and sysfs.  This makes this
>>>> test local to the filesystems involved and the results current of when
>>>> the mounts take place, removing a weird threading of the user
>>>> namespace, the mount namespace and the filesystems themselves.
>>>>
>>>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>>> ---
>>>>  fs/namespace.c                 |   37 +++++++++++++++++++++++++------------
>>>>  fs/proc/root.c                 |    7 +++++--
>>>>  fs/sysfs/mount.c               |    3 ++-
>>>>  include/linux/fs.h             |    1 +
>>>>  include/linux/user_namespace.h |    4 ----
>>>>  kernel/user.c                  |    2 --
>>>>  kernel/user_namespace.c        |    2 --
>>>>  7 files changed, 33 insertions(+), 23 deletions(-)
>>>>
>>>> diff --git a/fs/namespace.c b/fs/namespace.c
>>>> index 64627f8..877e427 100644
>>>> --- a/fs/namespace.c
>>>> +++ b/fs/namespace.c
>>>> @@ -2867,25 +2867,38 @@ bool current_chrooted(void)
>>>>  	return chrooted;
>>>>  }
>>>>  
>>>> -void update_mnt_policy(struct user_namespace *userns)
>>>> +bool fs_fully_visible(struct file_system_type *type)
>>>>  {
>>>>  	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
>>>>  	struct mount *mnt;
>>>> +	bool visible = false;
>>>>  
>>>> -	down_read(&namespace_sem);
>>>> +	if (unlikely(!ns))
>>>> +		return false;
>>>> +
>>>> +	namespace_lock();
>>>>  	list_for_each_entry(mnt, &ns->list, mnt_list) {
>>>> -		switch (mnt->mnt.mnt_sb->s_magic) {
>>>> -		case SYSFS_MAGIC:
>>>> -			userns->may_mount_sysfs = true;
>>>> -			break;
>>>> -		case PROC_SUPER_MAGIC:
>>>> -			userns->may_mount_proc = true;
>>>> -			break;
>>>> +		struct mount *child;
>>>> +		if (mnt->mnt.mnt_sb->s_type != type)
>>>> +			continue;
>>>> +
>>>> +		/* This mount is not fully visible if there are any child mounts
>>>> +		 * that cover anything except for empty directories.
>>>> +		 */
>>>> +		list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
>>>> +			struct inode *inode = child->mnt_mountpoint->d_inode;
>>>> +			if (!S_ISDIR(inode->i_mode))
>>>> +				goto next;
>>>> +			if (inode->i_nlink != 2)
>>>> +				goto next;
>>>
>>>
>>> I met a problem that proc filesystem failed to mount in user namespace,
>>> The problem is the i_nlink of sysctl entries under proc filesystem is not
>>> 2. it always is 1 even it's a directory, see proc_sys_make_inode. and for
>>> btrfs, the i_nlink for an empty dir is 2 too. it seems like depends on the
>>> filesystem itself,not depends on vfs. In my system binfmt_misc is mounted
>>> on /proc/sys/fs/binfmt_misc, and the i_nlink of this directory's inode is
>>> 1.
> 
> Yes. 1 is what filesystems that are too lazy to count the number of
> links to a directory return, and /proc/sys is currently such a
> filesystem.
> 
> Ordinarily nlink == 2 means a directory does not have any subdirectories.
> 
>>> btw, I'm not quite understand what's the inode->i_nlink != 2 here means?
>>> is this directory empty? as I know, when we create a file(not dir) under
>>> a dir, the i_nlink of this dir will not increase.
>>>
>>> And another question, it looks like if we don't have proc/sys fs mounted,
>>> then proc/sys will be failed to be mounted?
>>>
>>
>> Any Idea?? or should we need to revert this patch??
> 
> The patch is mostly doing what it is supposed to be doing.
> 
> Now the code is slightly buggy.  inode->i_nlink will test to see if a
> directory has subdirectories but it won't test to see if a directory is
> empty.  Where did my brain go when I was writing that test?
> 
> Right now I would rather not have the empty directory exception than
> remove this code.
> 
> The test is a little trickier to write than it might otherwise be
> because /proc and /sys tend to be slightly imperfect filesystems.
> 
> I think the only way to really test that is to call readdir on the
> directory itself :(  I don't like that thought.
> 
> I don't know what I was thinking when I wrote that test but I definitely
> goofed up.  Grr!
> 
> I can certainly filter out any directory with nlink > 2.  That would be
> an easy partial step forward.
> 
> The real question though is how do I detect directories it is safe to
> mount on where there will not be files in them.  I can't call iterate
> with the namespace_lock held so things are a bit tricky.
> 

I know this problem is not easy to be resolved. why not let the user
make the decision?  maybe we can introduce a new mount option MS_LOCK,
if user wants to use mount to hide something, he should use mount with
option MS_LOCK. so the unpriviged user can't umount this filesystem and
fail to mount the filesystem if one of it's child mount is mounted with
MS_LOCK option otherwise he use MS_REC too.

Thanks
