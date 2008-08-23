From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 04/10] user namespaces: enforce usernamespaces for file
	permission
Date: Fri, 22 Aug 2008 20:41:10 -0700
Message-ID: <m18wuo5rft.fsf@frodo.ebiederm.org>
References: <20080822194513.GA10262@us.ibm.com>
	<20080822194609.GD10360@us.ibm.com>
	<m1bpzkhhy0.fsf@frodo.ebiederm.org>
	<20080823005304.GA21064@us.ibm.com>
	<m1r68gebop.fsf@frodo.ebiederm.org>
	<20080823022210.GA29618@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080823022210.GA29618-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 22 Aug 2008 21:22:10 -0500")
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

>> There are two questions.
>> Does this filesystem provide mappings to user namespace X?
>> What is the mapping from this filesystem to user namespace X?
>
> That is where you and I still disagree:  I don't believe that a mapping
> as such makes sense.
>
> A mapping implies "uid 500 becomes uid 0, uid 501 becomes uid 1000",
> etc.  That simply is not sufficient.  If I am going to be able to create
> a new userns without privilege, then all files belonging to all uids in
> the child userns must be owned by uid 500 in my parent uidns.

> So I do think we will have to have something more of the format "what is
> the owning uid and gid of this inode, in the context of user namespace X."
> Which was the s_convert_uid_gid() in my helpers.

That is what I meant by mapping.  ;)

Given my thought in my last message that we should cache the user_ns
in the inode along with the rest of the credentials.  Making all of
the child files appear and act as if they are owned by uid 500 in the
parent namespace should be straight forward.

I think we may want a 1-1 mapping onto the filesystem.  However I
don't care very much how we store uids on the filesystem as long
as we do something that works.

> If we follow your userns:capability idea and then we probably can get
> rid of the s_is_capable you hated so much :)

yep.

> But,
>
>> I think we may be able to separate those two questions.
>> 
>> The important idea is that we don't need to implement filesystem changes
>> in the first pass.  Just have the permission check fail unconditionally
>> if we are not in the init_user_ns.
>> 
>> Eric
>
> There I definately agree.
>
> However, given this general direction, do you feel that marking an sb
> with a userns the way I'm doing in patch 4/10 makes sense, using it
> only to facilitate a basic "is this non-userns-aware fs in the same
> userns as the task attempting to access it" check?  If not, what
> alternatives do we have, given that marking vfsmounts as we've
> discussed before won't be feasible?
>
> Of course by the time we get capabilities straightened out I
> suppose tagging vfsmounts might in fact be feasible  :-)

LOL

Well I tell you what.  Unless we can think of a reason for a
file to live in more than one leaf user namespace.  We should
tag the inode with the leaf user namespace.

We could tag the superblock with a default for the inode user
namespace but that is less interesting.

Eric
