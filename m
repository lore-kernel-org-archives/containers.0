From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: acl_permission_check: disgusting performance
Date: Thu, 12 May 2011 17:29:07 -0700
Message-ID: <BANLkTi=nc3WGaASQm1Pc9byshLOmLf2bXQ__32203.4962512136$1305246745$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

So since we now do pathname lookup so well, I've been doing profiles
and looking at which parts are still problematic.

And some of them are just because it's real work to look up filenames.
So testing one of my favorite stupid loads ("do 'make' on a kernel
that is basically already made"), I'm not at all upset when I see
profiles that say

    25.91%           make  make                          [.] 0x1e78
     5.41%           make  [kernel.kallsyms]             [k] __d_lookup_rcu
     4.45%           make  [kernel.kallsyms]             [k] link_path_walk

although I do wonder what make is doing that makes it so slow.
Whatever. The kernel part looks rather good.

Except looking down, almost 2% of the time is spent in
"acl_permission_check()"! That's just disgusting. The function should
be instantaneous. It's a really trivial function. But it gets called a
_lot_.

Now part of it is that the code generated for it was just bad. We
should inline the call to "current_user_ns()", because immediately
afterwards we do "current_fsuid()", and a lot of it is shared (they
both access "current->cred"). Easy enough (just use
"_current_user_ns()" instead, to inline it). And let's not use
"mode_t", use "unsigned int" and gcc generates better code.

Fine. That gets us down a bit, so now it's not the third-hottest
kernel function, now it's just the fifth-hottest one:

     1.67%           make  [kernel.kallsyms]             [k] __strncpy_from_user
     1.39%           make  [kernel.kallsyms]             [k] do_lookup
     1.28%           make  [kernel.kallsyms]             [k]
acl_permission_check

which is still really quite depressing.

The annotated profile tells the story:

    7.36 :      ffffffff810bcd52:       65 48 8b 04 25 80 b5    mov
%gs:0xb580,%rax
    9.71 :      ffffffff810bcd67:       48 8b 80 18 03 00 00    mov
0x318(%rax),%rax
   15.34 :      ffffffff810bcd71:       48 8b 70 70             mov
0x70(%rax),%rsi
   30.57 :      ffffffff810bcd79:       48 81 7e 58 00 3b a4    cmpq
$0xffffffff81a43b00,0x58(%rsi)

Those four instructions are about two thirds of the cost of the
function. The last two are about 50% of the cost.

They are the accesses to "current", "->cred", "->user" and "->user_ns"
respectively (the cmp with the big constant is that compare against
"init_ns").

Now, if we got rid of them, we wouldn't improve performance by 2/3rds
on that function, because we do need the two first accesses for
"fsuid" (which is the next check), and the third one (which is
currently "cred->user" ends up doing the cache miss that we'd take for
"cred->fsuid" anyway. So the first three costs are fairly inescapable.

They are also cheaper, probably because those fields tend to be more
often in the cache. So it really is that fourth one that hurts the
most, as shown by it taking almost a third of the cycles of that
function.

And it all comes from that annoying commit e795b71799ff0 ("userns:
userns: check user namespace for task->file uid equivalence checks"),
and I bet nobody involved thought about how expensive that was.

That "user_ns" is _really_ expensive to load. And the fact that it's
after a chain of three other loads makes it all totally serialized,
and makes things much more expensive.

Could we perhaps have "user_ns" directly in the "struct cred"? Or
could we avoid or short-circuit this check entirely somehow, since it
always checks against "init_ns"?

It's sad seeing that long chain of accesses and how nasty it gets (and
interesting but perhaps not surprising how it also clearly gets colder
from the cache the further away from "current" that it is).

It's extra sad, considering that almost nobody gets any _advantage_
from that stupid user_ns test. So it really is wasted time.

                            Linus
