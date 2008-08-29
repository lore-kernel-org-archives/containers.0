From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Fri, 29 Aug 2008 11:02:52 +0200
Message-ID: <48B7BB3C.5080404@fr.ibm.com>
References: <20080821022126.GA29449@us.ibm.com> <48ACD6CB.5030706@zytor.com>
	<20080821031028.GB30205@us.ibm.com>
	<48ACDDC7.3000704@zytor.com> <48AD991F.9010906@fr.ibm.com>
	<48AD9A97.6000807@zytor.com> <48AD9DCD.3060306@fr.ibm.com>
	<m1fxoys1ng.fsf@frodo.ebiederm.org> <48ADD7D3.7080400@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48ADD7D3.7080400-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> Eric W. Biederman wrote:
>> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> H. Peter Anvin wrote:
>>>> Cedric Le Goater wrote:
>>>>>> I suggest "newinstance", but "newns" works, too.
>>>>> Could we also use this mount option to 'unshare' a new posix message
>>>>> queue namespace ?
>>>> Sorry, I fail to see the connection with devpts here?  Are you
>>>> suggesting using the same option for another filesystem (if so, which)?
>>> yes. the posix message queues are also using a single superblock filesystem. 
>>>
>>> If we want isolate them (for container needs for example), we also need to 
>>> create a new sb. The patchset I have uses a clone flag but using a mount 
>>> 'newns' really sounds like a better idea.
>> Let's call it newinstance if we are going to use the same option for devpts.
> 
> ok.
> 
>> We can update "current->nsproxy->mqueuens" when the newinstance flag is passed
>> and otherwise we can mount whatever is the current mqueue filesystem for
>> the process.
> 
> yes. I'll rebase my previous patchset on this idea.

Hello Eric,

I've spent some time on the code and I'm facing some issues with the nsproxy 
API if we are to keep the mqueue namespace in nsproxy: 

	int copy_namespaces(unsigned long flags, struct task_struct *tsk);
	void exit_task_namespaces(struct task_struct *tsk);
	void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
	void free_nsproxy(struct nsproxy *ns);
	int unshare_nsproxy_namespaces(unsigned long, struct nsproxy **,
		struct fs_struct *);

nsproxy designed to work closely with the clone flags and it is not well
suited to be called elsewhere than clone/unshare.

So I could either : 

(1) make a special case for the mqueue namespace and duplicate some code 
    to unshare it from ->get_sb() when the option 'newinstance' is used.

(2) to avoid duplicating code, use a clone_flags to unshare the mqueue 
    namespace from ->get_sb() when the option 'newinstance' is used. that 
    sounds silly because we might as well use sys_unshare() in that case.

(3) move mq_ns out of nsproxy.  where shall I put it then ? 

    (3.1) task_struct ? 
    (3.2) mnt namespace maybe ?



BTW, have you taken a look at what dave resent in July ? 

	https://lists.linux-foundation.org/pipermail/containers/2008-July/011776.html

This is the mqueue namespace patchset using CLONE_NEWIPC to unshare.
 
I wonder if there are arguments against that approach. I might have 
forgotten some of the issues with unshare as I haven't looked at the 
code for some time.

Thanks !

C.
