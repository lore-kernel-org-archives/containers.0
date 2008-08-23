From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 04/10] user namespaces: enforce usernamespaces for file
	permission
Date: Fri, 22 Aug 2008 18:56:38 -0700
Message-ID: <m1r68gebop.fsf@frodo.ebiederm.org>
References: <20080822194513.GA10262@us.ibm.com>
	<20080822194609.GD10360@us.ibm.com>
	<m1bpzkhhy0.fsf@frodo.ebiederm.org>
	<20080823005304.GA21064@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080823005304.GA21064-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 22 Aug 2008 19:53:04 -0500")
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
> By itself that is not sufficient.  We need to support two inodes on the
> same fs where both have i_uid=500 on the host fs, while in user
> namespace X one is owned by uid 0, and another by uid 1000.
>
> So we need to be able to pass the filesystem an inode and a user
> namespace, and ask for the owning uid and gids.
>
> Or am I (I likely am) misunderstanding?

There are two questions.
Does this filesystem provide mappings to user namespace X?
What is the mapping from this filesystem to user namespace X?

I think we may be able to separate those two questions.

The important idea is that we don't need to implement filesystem changes
in the first pass.  Just have the permission check fail unconditionally
if we are not in the init_user_ns.

Eric
