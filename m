From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 4/6] user namespaces: add user_ns to super block
Date: Tue, 29 Jul 2008 12:22:13 -0700
Message-ID: <m13alscx7e.fsf@frodo.ebiederm.org>
References: <20080726002700.GA29686@us.ibm.com>
	<20080726002754.GD29874@us.ibm.com>
	<m13altislf.fsf@frodo.ebiederm.org>
	<1217285230.25300.19.camel@localhost.localdomain>
	<20080729180515.GB365@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080729180515.GB365-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue, 29 Jul 2008 13:05:15 -0500")
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

>
> The filesystem can figure that out based on current's context, no?
>
> With the per-sb user_ns, the default behavior is indeed very limited,
> but since you want to move all the user_ns functionality into the
> filesystem, the fs can tag vfsmounts based on the "new remount" you
> had talked about before.

I guess I want the filesystem to coordinate.

>> 	Would this require passing the vfsmount to the filesystems themselves,
>> or would they be within the VFS code only? If not wholly within the VFS
>> I wonder if Al Viro would object to this. He's resisted past attempts to
>> pass the vfsmount structs into more filesystem code paths and I'm
>> guessing that could affect whether or not this approach can be
>> implemented.
>
> Right, that's the main reason we might want to pursue the per-sb
> approach.  Otherwise I would prefer the per-vfsmount approach.
>
> Eric, if you think the per-vfsmount fight is worth fighting, then by all
> means let's do it and see what happens.  So in that case ignore patches
> 3-5 from this set :)

My intuitive sense is that the treating the handling of different
user namespaces in the same filesystem is a trivial case of the
superblock merging that nfs performs.  And that we will preserve
existing semantics much better if the user namespace is stored
in the vfsmount.  This allows mount propagation and friends to work
without surprises.

The practical limitation I see of storing things outside of the
vfsmount is when do you setup the mapping to handle a new user
namespace?

So yes.  I think it is worth the discussion.  Let's not
move the vfsmount down, and just move the user namespace pointer
down as that is fundamentally what we care about.

Eric
