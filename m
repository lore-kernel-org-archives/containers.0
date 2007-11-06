From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: namespaces compatibility list
Date: Tue, 06 Nov 2007 10:46:23 -0700
Message-ID: <m1r6j35ksw.fsf@ebiederm.dsl.xmission.com>
References: <47304729.8000309@openvz.org> <4730640D.9030407@fr.ibm.com>
	<4730655C.8000306@openvz.org> <47308FDB.4010302@fr.ibm.com>
	<473091F9.10406@openvz.org> <47309A51.1050607@fr.ibm.com>
	<m1ejf371hw.fsf@ebiederm.dsl.xmission.com> <47309FAD.90702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47309FAD.90702-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Tue,
	06 Nov 2007 20:09:01 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
>>> right. I think we can address Ulrich concerns first because we have 
>>> a solution for it (which looks like unsharing all namespaces at once,
>>> here comes back the container object story :)
>> 
>> It doesn't work because we can't create a fresh mount namespace.
>> 
>> We need to create all new mounts (and deny access to the old ones)
>> if we want to prevent all possibility of user space goof ups.
>> 
>> While that is easy enough to build an application to do we can't
>> easily enforce that in the kernel.  Currently this is all
>> CAP_SYS_ADMIN so only root can do this anyway.  So we can easily
>> say don't do that then.
>> 
>> Clone flag consistency checking should only be used to enforce
>> cases where the kernel side cannot support correctly.  Currently
>> the kernel has no problems with the current mix and match possibilities
>> short of implementation deficiencies.  So I do not see us
>> addressing Ulrich's concerns with clone flags.
>
> ACK :) Since this all is CAP_SYS_ADMIN-ed we can do with just a warning.

So to restate.

clone flags consistency checks are for things the kernel can't do or
   for things that the kernel can't do securely.

If all we do is confuse user space if used improperly it's simply
a don't do that then.

CAP_SYS_ADMIN keeps us untrusted applications from confusing suid
executables, which is the only case where confusion counts as a
security hole.

Eric
