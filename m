From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 0/9] Multiple devpts instances
Date: Mon, 23 Feb 2009 22:19:34 +0100
Message-ID: <49A312E6.9090900@free.fr>
References: <20081015053000.GA2039@us.ibm.com> <499D7E13.10601@free.fr>
	<499D97B1.1090902@zytor.com> <499DA069.3040603@free.fr>
	<499DB9DA.2070301@zytor.com> <499DE06E.4030108@free.fr>
	<m1eixuvv00.fsf@fess.ebiederm.org>
	<20090223205609.GA32351@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090223205609.GA32351-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>   
>> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
>>
>>     
>>> But if I am able to create a new instance of devpts for a container and modify
>>> the configuration of another devpts from this container, is it acceptable ? Can
>>> we convince people to use the containers for security and have anybody able to
>>> make a pty starvation from one container to another ?
>>>       
>> I hardly how that is significant.  Anyone can allocate the rest of the possible
>> pty's today.  The situation does not get worse with devpts.
>>
>> If you want security and permission arguments get with Serge and finish
>> the uid namespace.  The you will have a user that looks like root but
>> does not have permissions to do most things.
>>     
>
> Right, and in particular the way it would partially solve this issue is
> that the procsys limit file would be owned by root in the initial uid
> namespace, so root in a child container would not be able to write to
> it.
>
> Defining a new mount option to set a per-sb limit seems useful though,
> as I could easily see wanting to limit containers (on a 1000-container
> system) to 3 ptys each for instance.
>   

Yep,  I changed my mind, I think Eric and HPA are right. devpts is a 
file system and not a namespace even if the result is the same. That 
makes sense to keep a global sysctl for the root container and handle 
security problem with user namespace and mount option.

>>> If it is too much complicated to handle one value per new devpts instance, IMHO
>>> /proc/sys/kernel/pty/max should be, at least, read-only for the new instance, no?
>>>       
>> No.  Either we add a pty_max value to the filesystem like we did with ptmx
>> or we forget it.
>>     
>
> -serge
>
>
>   
