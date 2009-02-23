From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] Multiple devpts instances
Date: Mon, 23 Feb 2009 16:27:15 -0600
Message-ID: <20090223222715.GA2270@us.ibm.com>
References: <20081015053000.GA2039@us.ibm.com> <499D7E13.10601@free.fr>
	<499D97B1.1090902@zytor.com> <499DA069.3040603@free.fr>
	<499DB9DA.2070301@zytor.com> <499DE06E.4030108@free.fr>
	<m1eixuvv00.fsf@fess.ebiederm.org>
	<20090223205609.GA32351@us.ibm.com> <49A31299.8040501@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49A31299.8040501-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting H. Peter Anvin (hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org):
> Serge E. Hallyn wrote:
>>>
>>> If you want security and permission arguments get with Serge and finish
>>> the uid namespace.  The you will have a user that looks like root but
>>> does not have permissions to do most things.
>>
>> Right, and in particular the way it would partially solve this issue is
>> that the procsys limit file would be owned by root in the initial uid
>> namespace, so root in a child container would not be able to write to
>> it.
>>
>
> No, uid namespace is not the right thing for this.  If anything, it  

For what?  uid ns is right for file access controls among namespaces,
and I'm just detailing what the uid ns file controls will buy you in
terms of the procsys limits file...

I actually do prefer having the file write handler check for
CAP_SYS_RESOURCE, but have conceded that battle at least in the
cgroup arena.

> should be controlled by a capability flag.  This is a general issue for  
> procfs and sysfs as used for controlling any kind of system resources,  
> though.
>
>> Defining a new mount option to set a per-sb limit seems useful though,
>> as I could easily see wanting to limit containers (on a 1000-container
>> system) to 3 ptys each for instance.
>
> What probably would make more sense is to limit containers to a specific  
> number of inodes or open file descriptors.  The pty limit was a quick  
> hack to avoid DoS, but it's really equivalent (with a small multiplier,  
> ~3 or so) to "open inodes".

Yes that (# inodes) sounds good.

thanks,
-serge
