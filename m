From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Wed, 03 Sep 2008 14:04:01 +0200
Message-ID: <48BE7D31.7040507@fr.ibm.com>
References: <20080821022126.GA29449@us.ibm.com> <48ACD6CB.5030706@zytor.com>
	<20080821031028.GB30205@us.ibm.com>
	<48ACDDC7.3000704@zytor.com> <48AD991F.9010906@fr.ibm.com>
	<48AD9A97.6000807@zytor.com> <48AD9DCD.3060306@fr.ibm.com>
	<m1fxoys1ng.fsf@frodo.ebiederm.org>
	<48ADD7D3.7080400@fr.ibm.com> <48B7BB3C.5080404@fr.ibm.com>
	<m1d4jmhpgl.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1d4jmhpgl.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>> Hello Eric,
>>
>> I've spent some time on the code and I'm facing some issues with the nsproxy 
>> API if we are to keep the mqueue namespace in nsproxy: 
>>
>> 	int copy_namespaces(unsigned long flags, struct task_struct *tsk);
>> 	void exit_task_namespaces(struct task_struct *tsk);
>> 	void switch_task_namespaces(struct task_struct *tsk, struct nsproxy
>> *new);
>> 	void free_nsproxy(struct nsproxy *ns);
>> 	int unshare_nsproxy_namespaces(unsigned long, struct nsproxy **,
>> 		struct fs_struct *);
>>
>> nsproxy designed to work closely with the clone flags and it is not well
>> suited to be called elsewhere than clone/unshare.
> 
> Right.
> 
>> So I could either : 
>>
>> (1) make a special case for the mqueue namespace and duplicate some code 
>>     to unshare it from ->get_sb() when the option 'newinstance' is used.
> 
> This is probably the best option. 
> 
> You should be able to just wrap create_new_namespaces(flags=0,...)
> to create a new one.
> 
> And then actually perform the unshare.
> 
> Which means in practice you will bump the ref count on
> mq_ns and then drop it and insert a new mq_ns pointer but overall
> that shouldn't be too bad.

Thanks for the comments, Eric. I should have something ready soon.

I'm currently reviewing the C/R patches that have been sent recently.

C.
