From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 4/6] user namespaces: add user_ns to super block
Date: Mon, 28 Jul 2008 14:53:00 -0700
Message-ID: <m13altislf.fsf@frodo.ebiederm.org>
References: <20080726002700.GA29686@us.ibm.com>
	<20080726002754.GD29874@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080726002754.GD29874-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Fri, 25 Jul 2008 19:27:54 -0500")
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

>>From 420d6e81ce29d7a6fe3ab7b43c1171e105f8b697 Mon Sep 17 00:00:00 2001
> From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Thu, 24 Jul 2008 18:00:54 -0500
> Subject: [PATCH 4/6] user namespaces: add user_ns to super block
>
> Add a user_ns to the super_block, and set it to the user_ns of
> the process which mounted the fs.
>
> In generic_permission() compare the current user_ns to that
> of the user_ns which mounted the inode's filesystem.

I don't think this is the right approach.

When we had the conversation earlier this was conceptually rejected
as it prevents nfs superblock unification.

We really want to store this in the vfsmount and pass the user namespace down
from there to where we are going to use it if at all possible.

The vfsmount also appears necessary if we are ever going to support multiple
user namespaces per filesystem as the filesystem still need to know which 
user namespace to interpret it's data in.

Eric
