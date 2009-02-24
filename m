From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/9] Multiple devpts instances
Date: Mon, 23 Feb 2009 20:09:25 -0800
Message-ID: <m1eixozdai.fsf@fess.ebiederm.org>
References: <20081015053000.GA2039@us.ibm.com> <499D7E13.10601@free.fr>
	<499D97B1.1090902@zytor.com> <499DA069.3040603@free.fr>
	<499DB9DA.2070301@zytor.com> <499DE06E.4030108@free.fr>
	<m1eixuvv00.fsf@fess.ebiederm.org> <20090223205609.GA32351@us.ibm.com>
	<49A31299.8040501@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49A31299.8040501-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> (H. Peter Anvin's message of "Mon\,
	23 Feb 2009 13\:18\:17 -0800")
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
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> writes:

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
> No, uid namespace is not the right thing for this.  If anything, it should be
> controlled by a capability flag.  This is a general issue for procfs and sysfs
> as used for controlling any kind of system resources, though.

Yes, it is a general issue.

The design we have on the table is actually a security credentials
namespace not a uid namespace.  It encompasses uids, gids,
capabilities, and keys.

One of the biggest design constraints is that it should be possible to
create a credentials namespace without permissions and not have to worry
about confusing suid root executables.  Which means in that context a suid
root executable needs to mean an executable from the perspective an observer
outside the credential namespace does not have elevated privileges.

Once we get there, whether it is a capability based resource check or
a uid based resource check there will be no access from inside of a
credentials namespace, because no processes will have permissions to
access the resource.  Which is what was asked for.

That neatly solves the proc and sysfs issues as well as many others such
as access to /etc/passwd.

Eric
