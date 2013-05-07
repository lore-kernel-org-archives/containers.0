From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Use CAP_SYS_RESOURCE as magic for escaping user
	namespaces.
Date: Tue, 7 May 2013 12:10:07 -0500
Message-ID: <20130507171007.GB10806@austin.hallyn.com>
References: <1367913689-3423-1-git-send-email-Janne.Karhunen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367913689-3423-1-git-send-email-Janne.Karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Janne Karhunen (janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Current state of the kernel appears to be that there are more
> than 1000 capable() calls and only handful are converted to
> ns_capable(). Moreover, it probably does not make any sense
> to convert most of these calls to be namespace aware due to
> the nature of the physical resources they control, making
> 'capable()' the right question to ask. Yet, in order to be
> able to build 'fully functional real device' like containers,
> user namespaces sometimes need the access to real system
> resources.
> 
> Thus, one potential candidate for enabling access to physical
> resources from the user namespace would be to use namespaces
> own CAP_SYS_RESOURCE as a magical token for making task
> capabilities valid for init_ns.
> 
> Signed-off-by: Janne Karhunen <Janne.Karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Uh, I would say nack, and if you need this then a device
namespace allowing you to 'pass' devices similarly to how you
pass a physical nic to a child netns is a part of the answer.

Your goals are not 100% clear to me.  What is it about a user
namespace that you want?
