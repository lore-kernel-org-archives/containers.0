From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: namespaces compatibility list
Date: Wed, 07 Nov 2007 12:29:04 +0300
Message-ID: <47318560.9020803@openvz.org>
References: <47304729.8000309@openvz.org>
	<4730640D.9030407@fr.ibm.com>	<4730655C.8000306@openvz.org>
	<47308FDB.4010302@fr.ibm.com>	<473091F9.10406@openvz.org>
	<47309A51.1050607@fr.ibm.com>
	<m1ejf371hw.fsf@ebiederm.dsl.xmission.com>
	<47309FAD.90702@openvz.org> <4731756A.3060701@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4731756A.3060701-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> Pavel Emelyanov wrote:
>> Eric W. Biederman wrote:
>>> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>>>> right. I think we can address Ulrich concerns first because we have 
>>>> a solution for it (which looks like unsharing all namespaces at once,
>>>> here comes back the container object story :)
>>> It doesn't work because we can't create a fresh mount namespace.
>>>
>>> We need to create all new mounts (and deny access to the old ones)
>>> if we want to prevent all possibility of user space goof ups.
>>>
>>> While that is easy enough to build an application to do we can't
>>> easily enforce that in the kernel.  Currently this is all
>>> CAP_SYS_ADMIN so only root can do this anyway.  So we can easily
>>> say don't do that then.
>>>
>>> Clone flag consistency checking should only be used to enforce
>>> cases where the kernel side cannot support correctly.  Currently
>>> the kernel has no problems with the current mix and match possibilities
>>> short of implementation deficiencies.  So I do not see us
>>> addressing Ulrich's concerns with clone flags.
>> ACK :) Since this all is CAP_SYS_ADMIN-ed we can do with just a warning.
> 
> Fine with me. 
> 
> Let's come back to the document, then.

:) Let's. Does anybody have any comments about the current text? :)

> C.
> 
