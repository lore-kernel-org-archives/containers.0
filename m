From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 21/29] Dump anonymous- and file-mapped-	shared
	memory
Date: Wed, 01 Apr 2009 19:18:14 -0400
Message-ID: <49D3F636.1070303@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-22-git-send-email-orenl@cs.columbia.edu>
	<20090401230657.GB27725@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090401230657.GB27725-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


Thanks for the review ...

Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> We now handle anonymous and file-mapped shared memory. Support for IPC
>> shared memory requires support for IPC first. We extend cr_write_vma()
>> to detect shared memory VMAs and handle it separately than private
>> memory.

[...]

>> +	switch (vma_type) {
>> +	case CR_VMA_SHM_FILE:
>> +		/* no need for contents that are stored in the file system */
>> +		ret = vfs_fsync(vma->vm_file, vma->vm_file->f_path.dentry, 0);
>> +		break;
>> +	case CR_VMA_SHM_ANON:
>> +		/* save the contents of this resgion */
>> +		inode = vma->vm_file->f_dentry->d_inode;
>> +		ret = cr_write_shmem_contents(ctx, inode);
>> +		break;
>> +	case CR_VMA_SHM_ANON_SKIP:
>> +	case CR_VMA_SHM_FILE_SKIP:
>> +		/* already saved before .. skip now */
>> +		break;
>> +	default:
>> +		BUG();
> 
> Well, no - since the user can feed in whatever crap they want,
> this isn't a *bug*, right?

... this is during checkpoint, no user input; it makes sure we don't
add a new type of VMA that we don't handle. On restart we complain
with -EINVAL.

[...]

> 
>>  struct cr_hdr_vma {
>>  	__u32 vma_type;
>> -	__u32 vma_objref;	/* for vma->vm_file */
>> +	__s32 vma_objref;	/* objref of backing file */
>> +	__s32 shm_objref;	/* objref of shared segment */
> 
> You're going to upset Alexey again with the signeds, aren't you?

Yes, I put a comment about signed values somewhere. I cleaned up most of
the unsigned instances following Alexey's comment, but I think in some
cases it makes sense.

In particular, assume I take a pid, or an objref, which is an 'int' in
the code, and save it with __u32. During restart I need to test for a
valid value before blindly converting back to (signed) int, like:
	
	ret = -EINVAL;
	if (hh->pid > INT_MAX)
		goto out;

in that case, I can just as well leave it signed and test

	ret = -EINVAL;
	if (hh->pid < 0)
		goto out;

which is much more readable, and less error-prone if sometime later
we change objref type from (signed) int to (signed) long and forget
to change INT_MAX to LONG_MAX everywhere ...

Oren.
