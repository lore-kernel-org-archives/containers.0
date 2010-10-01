From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] Replace pid_t in autofs4 with struct pid reference.
Date: Fri, 01 Oct 2010 12:48:38 +0200
Message-ID: <4CA5BC86.2040006@free.fr>
References: <1285840564-10251-1-git-send-email-daniel.lezcano@free.fr>
	<20100930223639.GA12959@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100930223639.GA12959-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Helmut Lichtenberg <heli-dxCdbQ03lbiELgA04lAiVw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/01/2010 12:36 AM, Serge Hallyn wrote:
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>    
>> I resurect and refreshed this old patch from
>> https://lists.linux-foundation.org/pipermail/containers/2007-February/003726.html
>>
>> This patch makes automount to work within a container.
>>
>> Make autofs4 container-friendly by caching struct pid reference rather
>> than pid_t and using pid_nr() to retreive a task's pid_t.
>>
>> ChangeLog:
>> 	- Refreshed against linux-next (added dev-ioctl.c)
>> 	- Fix Eric Biederman's comments - Use find_get_pid() to hold a
>> 	  reference to oz_pgrp and release while unmounting; separate out
>> 	  changes to autofs and autofs4.
>> 	- Also rollback my earlier change to autofs_wait_queue (pid and tgid
>> 	  in the wait queue are just used to write to a userspace daemon's
>> 	  pipe).
>>          - Fix Cedric's comments: retain old prototype of parse_options()
>>            and move necessary change to its caller.
>>
>> Signed-off-by: Sukadev Bhattiprolu<sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>
>> Cc: Ian Kent<raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
>> Cc: Cedric Le Goater<clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
>> Cc: Dave Hansen<haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Cc: Serge E. Hallyn<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Cc: Eric Biederman<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Cc: Helmut Lichtenberg<heli-dxCdbQ03lbiELgA04lAiVw@public.gmane.org>
>> ---
>>      

[ cut ]

>> @@ -133,7 +133,7 @@ static int autofs4_show_options(struct seq_file *m, struct vfsmount *mnt)
>>   		seq_printf(m, ",uid=%u", root_inode->i_uid);
>>   	if (root_inode->i_gid != 0)
>>   		seq_printf(m, ",gid=%u", root_inode->i_gid);
>> -	seq_printf(m, ",pgrp=%d", sbi->oz_pgrp);
>> +	seq_printf(m, ",pgrp=%d", pid_nr(sbi->oz_pgrp));
>>   	seq_printf(m, ",timeout=%lu", sbi->exp_timeout/HZ);
>>   	seq_printf(m, ",minproto=%d", sbi->min_proto);
>>   	seq_printf(m, ",maxproto=%d", sbi->max_proto);
>> @@ -263,6 +263,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>>   	int pipefd;
>>   	struct autofs_sb_info *sbi;
>>   	struct autofs_info *ino;
>> +	pid_t pgid;
>>
>>   	sbi = kzalloc(sizeof(*sbi), GFP_KERNEL);
>>   	if (!sbi)
>> @@ -275,7 +276,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>>   	sbi->pipe = NULL;
>>   	sbi->catatonic = 1;
>>   	sbi->exp_timeout = 0;
>> -	sbi->oz_pgrp = task_pgrp_nr(current);
>> +	sbi->oz_pgrp = task_pgrp(current);
>>   	sbi->sb = s;
>>   	sbi->version = 0;
>>   	sbi->sub_version = 0;
>> @@ -314,7 +315,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>>
>>   	/* Can this call block? */
>>   	if (parse_options(data,&pipefd,&root_inode->i_uid,&root_inode->i_gid,
>> -				&sbi->oz_pgrp,&sbi->type,&sbi->min_proto,
>> +				&pgid,&sbi->type,&sbi->min_proto,
>>   				&sbi->max_proto)) {
>>   		printk("autofs: called with bogus options\n");
>>   		goto fail_dput;
>> @@ -342,12 +343,19 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
>>   		sbi->version = sbi->max_proto;
>>   	sbi->sub_version = AUTOFS_PROTO_SUBVERSION;
>>
>> -	DPRINTK("pipe fd = %d, pgrp = %u", pipefd, sbi->oz_pgrp);
>> +	DPRINTK("pipe fd = %d, pgrp = %u", pipefd, pgid);
>> +
>> +	sbi->oz_pgrp = find_get_pid(pgid);
>>      
> This is a little backward.  You first get current's pgid pid, but don't
> take a reference;  then parse_options gets current's pgid pid_nr (and
> keeps that if no pgid was specified), passes that back here, and here we
> get the pid_nr and take a ref.  I was actually first going to say that
> I didn't want to block this patch on this, but it should be cleaned up
> at some point (i.e. at top of this function get the struct pid and get
> a ref, pass that to parse_options, and have parse_options get the
> specified pgid instead if a valid one was passed in.
>    

I agree, I will cleanup this part.

Also, I noticed the:

         ...
         case Opt_pgrp:
             if (match_int(args, &option))
                 return 1;
             *pgrp = option;
             break;
         ...

ouch !


> But now I'm wondering whether this actually is unsafe, bc I'm not quite
> sure how to read the comment above task_pgrp() (in sched.h) says not
> to dereference this if it wasn't gotten under task_lock or rcu_read_lock.
> Which this isn't.  So is this actually unsafe?
>    

Good point.

task_pgrp_nr calls __task_pid_nr_ns which does rcu_read_lock.
task_pgrp does not take any lock.

So you are right, replacing task_pgrp_nr by task_pgrp is unsafe.

I suppose get_task_pid(current, PIDTYPE_PGID) is the right call.


Thanks for looking at the patch.

   -- Daniel
