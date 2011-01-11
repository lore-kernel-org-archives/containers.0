From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/7] allow killing tasks in your own or child userns
Date: Mon, 10 Jan 2011 23:22:12 -0500
Message-ID: <4D2BDAF4.9040908@cs.columbia.edu>
References: <20110110211135.GA22446@mail.hallyn.com>	<20110110211334.GD22564@mail.hallyn.com>	<20110110215240.GA21351@wavehammer.waldi.eu.org>
	<20110110225151.GA18944@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110110225151.GA18944@localhost>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



On 01/10/2011 05:51 PM, Serge Hallyn wrote:
> Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
>> On Mon, Jan 10, 2011 at 09:13:34PM +0000, Serge E. Hallyn wrote:
>>> +	const struct cred *cred = current_cred();
>>> +	const struct cred *tcred = __task_cred(t);
>>> +
>>> +	if (cred->user->user_ns != tcred->user->user_ns) {
>>> +		/* userids are not equivalent - either you have the
>>> +		   capability to the target user ns or you don't */
>>> +		if (ns_capable(tcred->user->user_ns, CAP_KILL))
>>> +			return 1;
>>> +		return 0;
>>> +	}
>>> +
>>> +	/* same user namespace - usual credentials checks apply */
>>> +	if ((cred->euid ^ tcred->suid) &&
>>> +	    (cred->euid ^ tcred->uid) &&
>>> +	    (cred->uid  ^ tcred->suid) &&
>>> +	    (cred->uid  ^ tcred->uid) &&
>>> +	    !ns_capable(tcred->user->user_ns, CAP_KILL))
>>> +		return 0;
>>> +
>>> +	return 1;
>>
>> Isn't that equal to this?
>>
>> 	if (ns_capable(tcred->user->user_ns, CAP_KILL))
>> 		return 1;
>>
>> 	if (cred->user->user_ns == tcred->user->user_ns &&
>> 	    (cred->euid == tcred->suid ||
>> 	     cred->euid == tcred->uid ||
>> 	     cred->uid == tcred->suid ||
>> 	     cred->uid == tcred->uid))
>> 		return 1;
>>
>> 	return 0;
>>
>> I would consider this much easier to read.
> 
> Unfortunately, it's actually not equivalent.  when capable()
> returns success, then it sets the current->flags |= PF_SUPERPRIV.
> If permission is granted based on userids and the capability
> isn't needed, then we don't want to needlessly set PF_SUPERPRIV.

A bit off-topic: does this means that c/r needs to save and 
restore this process flag ?
> 
> That's why I'm going to such lengths to call capable() as a last
> resort.

IMHO, worth a one line comment in the code ...

Oren.
