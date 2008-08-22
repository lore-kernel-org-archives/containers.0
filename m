From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 04/10] user namespaces: enforce user namespaces for file
	permission
Date: Fri, 22 Aug 2008 14:13:11 -0700
Message-ID: <m1bpzkhhy0.fsf@frodo.ebiederm.org>
References: <20080822194513.GA10262@us.ibm.com>
	<20080822194609.GD10360@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080822194609.GD10360-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 22 Aug 2008 14:46:09 -0500")
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

> Add a user_ns to the sb.  It is always set to the user_ns of the task which
> mounted the sb.
>
> Define 3 new super_operations.  convert_uid() and convert_gid() take a uid
> or gid from an inode on the sb's fs, and attempt to convert them into ids
> meaningful in the user namespace passed in, which presumably is current's.
> is_capable() checks whether current has the requested capability with respect
> to the sb's fs, which is dependent upon the relationship between current's
> user_ns and those which the sb knows about.
>
> If the sb isn't user ns aware - which none are right now - then the new
> super_operations won't be defined.  If in that case current and sb have
> different user namespaces, then the userids can't be compared.
>
> If current's and sb's userids can't be compared, then current will get
> 'user other' (we usually say 'nobody') permissions to the inode.
>
> Changelog:
> 	Aug 5: send the whole inode to the super_operations.

Serge while I am dubious about adding the methods you have added to
super_block_operations there is one very important question you are
using them for that we do need to ask.

Does this filesystem map to user namespace X.

Can we separate that concept out as it's own individual function and initially
have a noop implementation that returns false for everything except for
the initial network namespace.

By doing just that we should be able to capture and update all of the tests without
the rest of the hassle.  Possibly this is just your s_convert_uid_gid function
without calling the superblock option.

I would really like to get to the point where we can create a user namespace
without privilege and have it be safe (if impotent).  Once we do that we can
extend out what the root of a user namespace is allowed to do, much as
we have done with the network namespace. 

Eric
