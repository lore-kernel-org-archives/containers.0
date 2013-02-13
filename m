From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 09/12] userns: Convert ocfs2 to use kuid and kgid
	where appropriate
Date: Wed, 13 Feb 2013 09:41:04 -0800
Message-ID: <878v6s158v.fsf@xmission.com>
References: <87pq38wimv.fsf@xmission.com>
	<1353415420-5457-1-git-send-email-ebiederm@xmission.com>
	<1353415420-5457-9-git-send-email-ebiederm@xmission.com>
	<20121121195940.GO2822@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121121195940.GO2822@localhost> (Joel Becker's message of "Wed,
	21 Nov 2012 11:59:41 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org> writes:

> On Tue, Nov 20, 2012 at 04:43:37AM -0800, Eric W. Biederman wrote:
>> diff --git a/fs/ocfs2/acl.c b/fs/ocfs2/acl.c
>> index 260b162..8a40457 100644
>> --- a/fs/ocfs2/acl.c
>> +++ b/fs/ocfs2/acl.c
>> @@ -65,7 +65,20 @@ static struct posix_acl *ocfs2_acl_from_xattr(const void *value, size_t size)
>>  
>>  		acl->a_entries[n].e_tag  = le16_to_cpu(entry->e_tag);
>>  		acl->a_entries[n].e_perm = le16_to_cpu(entry->e_perm);
>> -		acl->a_entries[n].e_id   = le32_to_cpu(entry->e_id);
>> +		switch(acl->a_entries[n].e_tag) {
>> +		case ACL_USER:
>> +			acl->a_entries[n].e_uid =
>> +				make_kuid(&init_user_ns,
>> +					  le32_to_cpu(entry->e_id));
>> +			break;
>
> Stupid question: do you consider disjoint namespaces on multiple
> machines to be a problem?  Remember that ocfs2 is a cluster filesystem.
> If I have uid 100 on machine A in the default namespace, and then I
> mount the filesystem on machine B with uid 100 in a different namespace,
> what happens?  I presume that both can access as the same nominal uid,
> and configuring this correctly is left as an exercise to the namespace
> administrator?

Yep.  That is the way it has been since nfs first gave us that
challenge.  Sane user administrators of shared filesystems use the same
uids for the same functions accross all machines that use that
filesystem.

That said it possible (but not implemented in these patches) to have
a notion of a filesystem that lives in another user namespace than the
initial user namespace.   Essentially by capturing the usernamespace
at mount time and storing it on the super block.  For the generic case
that requires a little bit of infrastructure work for quotas.

At this point my goal is to get all of the conversions into all of the
right places and then for the people who care do the work to allow
mounting their filesystem in another user namespace.

It is a very practical problem that user namespace support can not be
enabled when filesystems that have not had kuid/kgid support pushed down
into them are enabled in the kernel.  So I am working hard to push down
kuids and kgids and find all of the places that need conversions, so
enabling user namespaces will not cause incorrect kernel behavior
because the wrong types were used somewhere.

>> diff --git a/fs/ocfs2/dlmglue.c b/fs/ocfs2/dlmglue.c
>> index 4f7795f..f99af1c 100644
>> --- a/fs/ocfs2/dlmglue.c
>> +++ b/fs/ocfs2/dlmglue.c
>> @@ -2045,8 +2045,8 @@ static void __ocfs2_stuff_meta_lvb(struct inode *inode)
>>  	lvb->lvb_version   = OCFS2_LVB_VERSION;
>>  	lvb->lvb_isize	   = cpu_to_be64(i_size_read(inode));
>>  	lvb->lvb_iclusters = cpu_to_be32(oi->ip_clusters);
>> -	lvb->lvb_iuid      = cpu_to_be32(inode->i_uid);
>> -	lvb->lvb_igid      = cpu_to_be32(inode->i_gid);
>> +	lvb->lvb_iuid      = cpu_to_be32(i_uid_read(inode));
>> +	lvb->lvb_igid      = cpu_to_be32(i_gid_read(inode));
>
> 	I have the reverse question here.  Are we guaranteed that the
> on-disk uid/gid will not change regardless of the namespace?  That is,
> if I create a file on machine A in init_user_ns as uid 100, then access
> it over on machine B in some other namespace with a user-visible uid of
> 100, will the wire be passing 100 in both directions?  This absolutely
> must be true for the cluster communication to work.

The model I am working with is that for every filesystem there is
exactly one user namespace it stores the uids and gids in.   That user
namespace does not have to be the initial user namespace but there there
is one user namespace.

A user running in a user namespace different from the user namespace of
the filesystem will first have their uids and gids mapped to kuids and
kgids and then those kuids and kgids will be mapped to the on disk
representation.

Except for the odd ioctl or quota callback the vfs handles all of the
translation of uids and gids from user space to kuids and kgids.  Which
means the filesystems don't need to deal with what users are thinking,
and I don't need to teach filesystems to store an extended attribute
with user namespace information.

Which simplifies the problem for filesystems of dealing with kuid and
kgids coming from the vfs and translating those into the numbers you
want to store on disk.  Currently all filesystems are stored on disk in
the initial user namespace of the kernel.  So all of the conversions
into on disk structures are to the initial user namespace.

For network protocols there is the added challenge that you want to make
as certain as you can all of the parties are talking about uids and
gids in the same user namespace.  In general I make the assumption that
the filesystem's uid and gids are stored in the user namespace of the
process that mounts the filesystem, and those user space processes take
care of connecting you to other folks speaking of uids and gids in the
same user namespace.

In a few of my patches I have places where I can prevent and so I check
that the userspace process is in the initial user namespace and fail
otherwise.

Until someone does the work to deal with something other than the
initial user namespace in a filesystem and set the FS_USERNS_MOUNT flag
.fs_flags in struct filesystem a filesystem is guaranteed to always be
mounted in the initial user namespace.  So while there may be users in
other user namespaces the filesystem can just worring about getting
kuids and kgids and storing and communicating uids and gids in the
initial user namespace with the same logic it has always done.

Which is all a long way of saying if a user in another user namespace
with uid 100 which maps to uid 100100 in the initial user
namespace. Filesystems are expeted to treat that as a write from uid
100100 and if that isn't what the user who set up the other user
namespace wants to see in the on disk structures they should have used a
differenet mapping when setting up the user namespace.

And of course every uid maps in any user namespace has a lossless
mapping to and from the inital user namespace.

Hopefully that hopes to clear some confusion if there the intervening
time hadn't cleared that up.

Eric
