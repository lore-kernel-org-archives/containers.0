From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Tue, 02 Sep 2008 02:22:34 -0700
Message-ID: <m1d4jmhpgl.fsf@frodo.ebiederm.org>
References: <20080821022126.GA29449@us.ibm.com> <48ACD6CB.5030706@zytor.com>
	<20080821031028.GB30205@us.ibm.com> <48ACDDC7.3000704@zytor.com>
	<48AD991F.9010906@fr.ibm.com> <48AD9A97.6000807@zytor.com>
	<48AD9DCD.3060306@fr.ibm.com> <m1fxoys1ng.fsf@frodo.ebiederm.org>
	<48ADD7D3.7080400@fr.ibm.com> <48B7BB3C.5080404@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B7BB3C.5080404-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Cedric Le Goater's message of
	"Fri, 29 Aug 2008 11:02:52 +0200")
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
> Hello Eric,
>
> I've spent some time on the code and I'm facing some issues with the nsproxy 
> API if we are to keep the mqueue namespace in nsproxy: 
>
> 	int copy_namespaces(unsigned long flags, struct task_struct *tsk);
> 	void exit_task_namespaces(struct task_struct *tsk);
> 	void switch_task_namespaces(struct task_struct *tsk, struct nsproxy
> *new);
> 	void free_nsproxy(struct nsproxy *ns);
> 	int unshare_nsproxy_namespaces(unsigned long, struct nsproxy **,
> 		struct fs_struct *);
>
> nsproxy designed to work closely with the clone flags and it is not well
> suited to be called elsewhere than clone/unshare.

Right.

> So I could either : 
>
> (1) make a special case for the mqueue namespace and duplicate some code 
>     to unshare it from ->get_sb() when the option 'newinstance' is used.

This is probably the best option. 

You should be able to just wrap create_new_namespaces(flags=0,...)
to create a new one.

And then actually perform the unshare.

Which means in practice you will bump the ref count on
mq_ns and then drop it and insert a new mq_ns pointer but overall
that shouldn't be too bad.

> (2) to avoid duplicating code, use a clone_flags to unshare the mqueue 
>     namespace from ->get_sb() when the option 'newinstance' is used. that 
>     sounds silly because we might as well use sys_unshare() in that case.

We should be able to refactor the code so we don't have lots of
duplication.

> (3) move mq_ns out of nsproxy.  where shall I put it then ? 
>
>     (3.1) task_struct ? 
That is almost interesting.

>     (3.2) mnt namespace maybe ?
>

> BTW, have you taken a look at what dave resent in July ? 

I took a quick look.

> 	https://lists.linux-foundation.org/pipermail/containers/2008-July/011776.html
>
> This is the mqueue namespace patchset using CLONE_NEWIPC to unshare.
>  
> I wonder if there are arguments against that approach. I might have 
> forgotten some of the issues with unshare as I haven't looked at the 
> code for some time.

I don't know that there are any big issues.  But there is a
certain purity in saying the mq namespaces is it's own weird
global namespace that isn't connected to anything else.  Which
unfortunately happens to be the truth.

Eric
