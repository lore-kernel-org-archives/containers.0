From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Thu, 21 Aug 2008 10:45:07 -0700
Message-ID: <m1fxoys1ng.fsf@frodo.ebiederm.org>
References: <20080821022126.GA29449@us.ibm.com> <48ACD6CB.5030706@zytor.com>
	<20080821031028.GB30205@us.ibm.com> <48ACDDC7.3000704@zytor.com>
	<48AD991F.9010906@fr.ibm.com> <48AD9A97.6000807@zytor.com>
	<48AD9DCD.3060306@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48AD9DCD.3060306-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Cedric Le Goater's message of
	"Thu, 21 Aug 2008 18:54:37 +0200")
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> H. Peter Anvin wrote:
>> Cedric Le Goater wrote:
>>>>>
>>>> I suggest "newinstance", but "newns" works, too.
>>>
>>> Could we also use this mount option to 'unshare' a new posix message
>>> queue namespace ?
>> 
>> Sorry, I fail to see the connection with devpts here?  Are you
>> suggesting using the same option for another filesystem (if so, which)?
>
> yes. the posix message queues are also using a single superblock filesystem. 
>
> If we want isolate them (for container needs for example), we also need to 
> create a new sb. The patchset I have uses a clone flag but using a mount 
> 'newns' really sounds like a better idea.

Let's call it newinstance if we are going to use the same option for devpts.

We can update "current->nsproxy->mqueuens" when the newinstance flag is passed
and otherwise we can mount whatever is the current mqueue filesystem for
the process.

That should be simple and just work.

Eric
