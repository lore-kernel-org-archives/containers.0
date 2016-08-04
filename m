From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: Re: [PATCHv4] locks: Filter /proc/locks output on proc pid ns
Date: Thu, 4 Aug 2016 18:09:59 +0300
Message-ID: <57A35AC7.7040105@kyup.com>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470295588-9803-1-git-send-email-kernel@kyup.com>
	<1470310175.22052.3.camel@poochiereds.net>
	<874m707hhm.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874m707hhm.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Cc: bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 08/04/2016 05:09 PM, Eric W. Biederman wrote:
> Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org> writes:
> 
>> On Thu, 2016-08-04 at 10:26 +0300, Nikolay Borisov wrote:
>>> On busy container servers reading /proc/locks shows all the locks
>>> created by all clients. This can cause large latency spikes. In my
>>> case I observed lsof taking up to 5-10 seconds while processing around
>>> 50k locks. Fix this by limiting the locks shown only to those created
>>> in the same pidns as the one the proc fs was mounted in. When reading
>>> /proc/locks from the init_pid_ns proc instance then perform no
>>> filtering
>>>
>>>> Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
>>> ---
>>>  fs/locks.c | 4 ++++
>>>  1 file changed, 4 insertions(+)
>>>
>>> diff --git a/fs/locks.c b/fs/locks.c
>>> index ee1b15f6fc13..df038c27b19f 100644
>>> --- a/fs/locks.c
>>> +++ b/fs/locks.c
>>> @@ -2648,9 +2648,13 @@ static int locks_show(struct seq_file *f, void *v)
>>>  {
>>>>  	struct locks_iterator *iter = f->private;
>>>>  	struct file_lock *fl, *bfl;
>>>> +	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
>>>  
>>>>  	fl = hlist_entry(v, struct file_lock, fl_link);
>>>  
>>>> +	if (fl->fl_nspid && !pid_nr_ns(fl->fl_nspid, proc_pidns))
>>>> +		return 0;
>>> +
>>>>  	lock_get_status(f, fl, iter->li_pos, "");
>>>  
>>>>  	list_for_each_entry(bfl, &fl->fl_block, fl_block)
>>
>> Looks reasonable to me. Eric, any comments? If this looks alright I'll
>> go ahead and merge into my -next branch for v4.9.
> 
> Generally this looks good to me.
> 
> Some related nits.
> - We are not filtering the processes that are blocked waiting on the
>   lock.
> 
> - The same issue shows up in show_fd_locks.
> 
> - In lock_get_status the code should say:
>   if (fl->fl_nspid) {
>   	/* Don't let fl_pid change depending on who is reading the file */
>   	fl_pid = pid_nr_ns(fl->fl_nspid, proc_pidns);
>         /* If there isn't a fl_pid don't display who is waiting on the lock */
>         if (fl_pid == 0)
>            return;
>   } else {
>   	fl_pid = fl->fl_pid;
>   }
> 
>   All of which implies that lock_get_status needs to take proc_pidns
>   from it's caller, or derive proc_pidns from the seq_file.

Just had a quick look at the code. If the aforementioned change is
introduced in lock_get_status and proc_pidns is derived from the
seq_file, then the issue in show_fd_locks would also be fixed, correct?

We essentially want to skip showing locks for whose owner we don't have
a mapping in the current pidns hierarchy?


>   
> Eric
> 
