From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: acl_permission_check: disgusting performance
Date: Thu, 12 May 2011 21:26:28 -0700
Message-ID: <BANLkTim3cy8Jf3URYTW+cbr3nrdWVbsmGw__18779.3802041144$1305261395$gmane$org@mail.gmail.com>
References: <BANLkTi=nc3WGaASQm1Pc9byshLOmLf2bXQ@mail.gmail.com>
	<20110513025013.GA13209@mail.hallyn.com>
	<20110513040214.GA25270@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110513040214.GA25270-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 12, 2011 at 9:02 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
>
> I wonder how much this would help: =A0(only compile-tested)

So it should help a lot, but it breaks when CONFIG_USER_NS isn't even
set (the case that Eric fixed.

So instead, do this:

 (a) get rid of the "_current_user_ns()" thing. There is no reason to
have it, if it's directly off "current->cred", then it's cheaper to
inline it than have a function just for two pointer indirections.

 (b) do

  #ifdef CONFIG_USER_NS
    #define current_user_ns() (&init_user_ns)
  #else
    #define current_user_ns() (current_cred_xxx(user_ns))
  #endif

 (c) and then the rest of your patch (to actually initialize and set
"cred->user_ns") should be fine. But don't touch
acl_permission_check() at all - once you've fixed current_user_ns() to
DTRT, acl_permission_check will be ok.

Ok?

Then the compiler will do the right thing: in acl_permission_check()
it will see that current_user_ns() and "current_fsuid()" share 90% of
the code, and will CSE the "current_cred()" part (or, if
CONFIG_USER_NS isn't set, it will see a constant comparison of
&init_user_ns with itself, and generate no code for hat case). There's
no reason for you to do it for it, and when  you do it by hand you get
the !CONFIG_USER_NS case wrong.

Hmm? That should fix all the horrible code generation issues in
acl_permission_check. When CONFIG_USER_NS isn't set, it will generate
no code at all, and when it _is_ set, it will just generate two loads
from current->cred (one for user_ns, one for fsuid), which is about as
good as it gets.

                              Linus
