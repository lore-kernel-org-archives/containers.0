From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC V1] Replace pid_t in autofs4 with struct pid reference.
Date: Tue, 12 Oct 2010 18:06:29 +0200
Message-ID: <4CB48785.4030906@free.fr>
References: <1286299696-13955-1-git-send-email-daniel.lezcano@free.fr>
	<20101012154718.GA23137@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101012154718.GA23137-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Helmut Lichtenberg <heli-dxCdbQ03lbiELgA04lAiVw@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/12/2010 05:47 PM, Serge E. Hallyn wrote:
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
>>
>> V1:
>> 	- fixed pgrp option in parse_options
>> 	- used get_task_pid(current, PIDTYPE_PGID) instead of task_pgrp
>> 	- fixed how is passed the 'pgrp' argument autofs4_fill_super
>> 	- fixed bad pid conversion, was pid_vnr not pid_nr in autofs4_wait
>> V0:
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
>>      
> Acked-by: Serge E. Hallyn<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> Thanks, Daniel, this looks good!  Thanks for pushing this needed fix.
>    

Thanks for reviewing. I tried to do some 'stress' test and it appears 
there is a deadlock between two containers with the automount daemon, I 
will fix it and resend a new version.

   -- Daniel
