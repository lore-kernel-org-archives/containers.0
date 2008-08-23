From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 04/10] user namespaces: enforce user namespaces for file
	permission
Date: Fri, 22 Aug 2008 19:16:46 -0700
Message-ID: <m1myj4cw6p.fsf@frodo.ebiederm.org>
References: <20080822194513.GA10262@us.ibm.com>
	<20080822194609.GD10360@us.ibm.com>
	<m1ej4glsen.fsf@frodo.ebiederm.org>
	<20080823005715.GB21064@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080823005715.GB21064-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 22 Aug 2008 19:57:15 -0500")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> That might make sense.  I guess the problem is I started trying to
> handle generic permission.  But I don't need to...  the fs can
> provide its own permission, else we do the simple userns check.

Sounds right.

We really need that simple starting place where we can turn it all
on and you aren't allowed to do anything, then we can enable one
feature at a time from there.

Plus I can think of some uses for a user who isn't allowed to do
anything on a machine. ;)

> The user ns comes from the current task.  The fs must decide whether
> current->user->uid in current->user->user_ns has capabilities over
> the target file.  Only the fs can erify that the user is really
> uid=0 or has CAP_DAC_OVERRIDE, for instance, with respect to the file.

In the general case only the filesystem can make the call about what
powers we have over a specific file and the filesystem will make that
call when we pass it our kerberos ticket to the filesystem server, and
ask the filesystem to perform a specific operation.

In the common case the filesystem is just a reflection of our in memory
set of namespaces.  Getting the capability rules straight are going
to be a little interesting.  Essentially however for filesystems
I believe the rule is if I have CAP_DAC_OVERRIDE in the user namespace
of a user.  And that user creates a namespace.  Then I should have
CAP_DAC_OVERRIDE capability over that namespace as well.  Allowing
me to back up files in the unprivileged users namespace.

The common case is the only case that needs to be implemented
in generic kernel code.

Eric
