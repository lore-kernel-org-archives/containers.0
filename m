From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 12/16] userns: For /proc/self/{uid,
	gid}_map derive the lower userns from the struct file
Date: Mon, 19 Nov 2012 10:29:45 -0800
Message-ID: <87fw451m5i.fsf@xmission.com>
References: <87lidx8wbo.fsf@xmission.com>
	<1353337961-12962-1-git-send-email-ebiederm@xmission.com>
	<1353337961-12962-12-git-send-email-ebiederm@xmission.com>
	<20121119180322.GC1883@serge-ThinkPad-X130e>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121119180322.GC1883@serge-ThinkPad-X130e> (Serge Hallyn's
	message of "Mon, 19 Nov 2012 12:03:23 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> 
>> To keep things sane in the context of file descriptor passing derive the
>> user namespace that uids are mapped into from the opener of the file
>> instead of from current.
>> 
>> When writing to the maps file the lower user namespace must always
>> be the parent user namespace, or setting the mapping simply does
>> not make sense.  Enforce that the opener of the file was in
>> the parent user namespace or the user namespace whose mapping
>> is being set.
>
> Is there a reasonable use case for writing from the ns whose mapping
> is being set?  Are you expecting cases where the child opens the file
> and passes it back to the parent to set the mappings?

Passing the open mappings file no.  Although by using seq_user_ns I do
make certain the semantics are correct if the file descriptor is passed,
but I did that on general principles.

I expect a process in the user namespace to be able to meaningfully set
the mapping to some the current uid and the current gid.

I expect a process outside of the user namespace (the parent) to be able
to meaningfully set the mapping for a range of uids and gids.

The additional error cases are simply to deny cases that are not
currently handled in the code.  Like what happens if the global root
tries to set the mapping for a process that is a user namespace 3 layers
deep and creating a 4th layer.  For reads that combination can be
supported but for writes you have to write the uid in the new user
namespace and the uid in the user namespace just below or else it can
not be verified that there is a mapping in all parent user namespaces.

Eric

>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  kernel/user_namespace.c |   12 ++++++++++--
>>  1 files changed, 10 insertions(+), 2 deletions(-)
>> 
>> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
>> index ce92f7e..89f6eae 100644
>> --- a/kernel/user_namespace.c
>> +++ b/kernel/user_namespace.c
>> @@ -391,7 +391,7 @@ static int uid_m_show(struct seq_file *seq, void *v)
>>  	struct user_namespace *lower_ns;
>>  	uid_t lower;
>>  
>> -	lower_ns = current_user_ns();
>> +	lower_ns = seq_user_ns(seq);
>>  	if ((lower_ns == ns) && lower_ns->parent)
>>  		lower_ns = lower_ns->parent;
>>  
>> @@ -412,7 +412,7 @@ static int gid_m_show(struct seq_file *seq, void *v)
>>  	struct user_namespace *lower_ns;
>>  	gid_t lower;
>>  
>> -	lower_ns = current_user_ns();
>> +	lower_ns = seq_user_ns(seq);
>>  	if ((lower_ns == ns) && lower_ns->parent)
>>  		lower_ns = lower_ns->parent;
>>  
>> @@ -688,10 +688,14 @@ ssize_t proc_uid_map_write(struct file *file, const char __user *buf, size_t siz
>>  {
>>  	struct seq_file *seq = file->private_data;
>>  	struct user_namespace *ns = seq->private;
>> +	struct user_namespace *seq_ns = seq_user_ns(seq);
>>  
>>  	if (!ns->parent)
>>  		return -EPERM;
>>  
>> +	if ((seq_ns != ns) && (seq_ns != ns->parent))
>> +		return -EPERM;
>> +
>>  	return map_write(file, buf, size, ppos, CAP_SETUID,
>>  			 &ns->uid_map, &ns->parent->uid_map);
>>  }
>> @@ -700,10 +704,14 @@ ssize_t proc_gid_map_write(struct file *file, const char __user *buf, size_t siz
>>  {
>>  	struct seq_file *seq = file->private_data;
>>  	struct user_namespace *ns = seq->private;
>> +	struct user_namespace *seq_ns = seq_user_ns(seq);
>>  
>>  	if (!ns->parent)
>>  		return -EPERM;
>>  
>> +	if ((seq_ns != ns) && (seq_ns != ns->parent))
>> +		return -EPERM;
>> +
>>  	return map_write(file, buf, size, ppos, CAP_SETGID,
>>  			 &ns->gid_map, &ns->parent->gid_map);
>>  }
>> -- 
>> 1.7.5.4
>> 
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linuxfoundation.org/mailman/listinfo/containers
