From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Wed, 03 Sep 2008 15:52:11 +0200
Message-ID: <48BE968B.1000107@fr.ibm.com>
References: <20080821031028.GB30205@us.ibm.com> <48ACDDC7.3000704@zytor.com>
	<48AD991F.9010906@fr.ibm.com> <48AD9A97.6000807@zytor.com>
	<48AD9DCD.3060306@fr.ibm.com> <m1fxoys1ng.fsf@frodo.ebiederm.org>
	<48ADD7D3.7080400@fr.ibm.com> <48B7BB3C.5080404@fr.ibm.com>
	<20080902030426.GB12277@us.ibm.com> <48BE7845.6070500@fr.ibm.com>
	<20080903132307.GA9527@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080903132307.GA9527-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

>>> When a task does mq_open(name, flag), then name is in the mqueuefs
>>> found in current->nsproxy->mnt_namespace->mqns.
>>>
>>> But if a task does
>>>
>>> 	clone(CLONE_NEWMNT);
>>> 	mount --move /dev/mqueue /oldmqueue
>>> 	mount -o newinstance -t mqueue none /dev/mqueue
>>>
>>> then that task can find files for the old mqueuefs under
>>> /oldmqueue, while mq_open() uses /dev/mqueue since that's
>>> what it finds through its mnt_namespace.
>> That I don't like. 
>>
>> Even though posix mqueue objects can outlive a process, I don't think 
>> a process should be able to peek and poke in a message queue namespace 
>> other than his. this is the basic principle of the namespaces : 
>> isolation. Am I wrong ?
> 
> Yes you are wrong in this case.  In particular consider mounts
> propagation, which allows you to to examine both a child namespace's
> mounts namespace, and, through the child's /sys (presumably
> mounted under /vs1/sys), his network namespace and eventually
> device namespace.

but there are some accounting done which could be fooled, like the 
max number of mqueues or the number of bytes used by the mqueues which 
is on a user_struct basis. 

>> couldn't we just return EACCES ? (not posix) 
> 
> We could.  And if we think there is really no value in viewing
> a child namespace's mqueuefs then we may as well.  I just want
> to make it clear that the proposed semantics support it as an
> option.

This make sense

C.
