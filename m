From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH] exec: Don't exec files the userns root can not
	read.
Date: Wed, 19 Oct 2016 12:04:45 -0500
Message-ID: <87lgxkjmmq.fsf@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CAOQ4uxjyZF346vq-Oi=HwB=jj6ePycHBnEfvVPet9KqPxL9mgg@mail.gmail.com>
	<87mvi0mpix.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mvi0mpix.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Wed, 19 Oct 2016 08:33:58 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amir Goldstein <amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> Amir Goldstein <amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>>> diff --git a/fs/exec.c b/fs/exec.c
>>> index 6fcfb3f7b137..f724ed94ba7a 100644
>>> --- a/fs/exec.c
>>> +++ b/fs/exec.c
>>> @@ -1270,12 +1270,21 @@ EXPORT_SYMBOL(flush_old_exec);
>>>
>>>  void would_dump(struct linux_binprm *bprm, struct file *file)
>>>  {
>>> -       if (inode_permission(file_inode(file), MAY_READ) < 0)
>>> +       struct inode *inode = file_inode(file);
>>> +       if (inode_permission(inode, MAY_READ) < 0) {
>>> +               struct user_namespace *user_ns = current->mm->user_ns;
>>>                 bprm->interp_flags |= BINPRM_FLAGS_ENFORCE_NONDUMP;
>>> +
>>> +               /* May the user_ns root read the executable? */
>>> +               if (!kuid_has_mapping(user_ns, inode->i_uid) ||
>>> +                   !kgid_has_mapping(user_ns, inode->i_gid)) {
>>> +                       bprm->interp_flags |= BINPRM_FLAGS_EXEC_INACCESSIBLE;
>>> +               }
>>
>> This feels like it should belong inside
>> inode_permission(file_inode(file), MAY_EXEC)
>> which hopefully should be checked long before getting here??
>
> It is the active ingredient in capable_wrt_inode_uidgid and is indeed
> inside of inode_permission.
>
> What I am testing for here is if I have a process with a full
> set of capabilities in current->mm->user_ns will the inode be readable.
>
> I can see an argument for calling prepare_creds stuffing the new cred
> full of capabilities.  Calling override_cred.  Calling inode_permission,
> restoring the credentials.  But it seems very much like overkill and
> more error prone because of the more code involved.
>
> So I have done the simple thing that doesn't hide what is really going on.

At the same time I can see the addition of a helper function
bool ns_inode(struct user_namespace *user_ns, struct inode *inode)
{
	return kuid_has_mapping(user_ns, inode->i_uid) &&
        	kgid_has_mapping(user_ns, inode->i_gid);
}

That abstracts out the concept instead of open codes it.

Eric
