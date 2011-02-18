From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 2/9] security: Make capabilities relative to the user
	namespace.
Date: Sat, 19 Feb 2011 00:44:50 +0100
Message-ID: <4D5F0472.4000403__27981.8484596492$1298072840$gmane$org@free.fr>
References: <20110217150224.GA26334@mail.hallyn.com>
	<20110217150306.GB26395@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110217150306.GB26395-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 02/17/2011 04:03 PM, Serge E. Hallyn wrote:
> - Introduce ns_capable to test for a capability in a non-default
>    user namespace.
> - Teach cap_capable to handle capabilities in a non-default
>    user namespace.
>
> The motivation is to get to the unprivileged creation of new
> namespaces.  It looks like this gets us 90% of the way there, with
> only potential uid confusion issues left.
>
> I still need to handle getting all caps after creation but otherwise I
> think I have a good starter patch that achieves all of your goals.
>
> Changelog:
> 	11/05/2010: [serge] add apparmor
> 	12/14/2010: [serge] fix capabilities to created user namespaces
> 	Without this, if user serge creates a user_ns, he won't have
> 	capabilities to the user_ns he created.  THis is because we
> 	were first checking whether his effective caps had the caps
> 	he needed and returning -EPERM if not, and THEN checking whether
> 	he was the creator.  Reverse those checks.
> 	12/16/2010: [serge] security_real_capable needs ns argument in !security case
> 	01/11/2011: [serge] add task_ns_capable helper
> 	01/11/2011: [serge] add nsown_capable() helper per Bastian Blank suggestion
> 	02/16/2011: [serge] fix a logic bug: the root user is always creator of
> 		    init_user_ns, but should not always have capabilities to
> 		    it!  Fix the check in cap_capable().
>
> Signed-off-by: Eric W. Biederman<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Serge E. Hallyn<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---

Acked-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
