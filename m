From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 0/4] Loopback mount escape fixes
Date: Fri, 24 Jul 2015 15:39:02 -0500
Message-ID: <87wpxp70k9.fsf__39995.8499162041$1437770770$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<CAELBmZBCCC1dspo4rPkFfh3c6RZBUYAZpz0tbUSukcf9att7Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAELBmZBCCC1dspo4rPkFfh3c6RZBUYAZpz0tbUSukcf9att7Cw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Mon, 13 Apr 2015 14:18:40 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org> writes:

> On Thu, Apr 9, 2015 at 1:31 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> After the last round of feedback I sat down and played with my fix
>> for the fact that a strategically placed rename, ".." on bind mounts
>> go up past the root of the bind mount.
>>
>> The code better handles the escaped directory returning into it's bind
>> mount, and is now roughly a constant factor cost in all cases from what
>> the code costs without the fix.
>>
>> So I think I have found a better tradeoff between fixing this bug and
>> not slowing down path name lookups in the common case.
>
> Maybe I'm missing something, but I see a much simpler fix:
>
>  - When following ".." first just check against the dentry being equal
> to the root dentry.
>
>  - If so, then check mount being equal to root mount.
>
>  - If so, then we are fine, found the root.
>
>  - If mount is not root mount, then we either have a bind mount or the
> escape scenario. So have a peek at the mount tree to see if we have a
> chance of reaching root or not.
>
>   - If yes, then we are fine, continue upward.
>
>   - Otherwise stop here and act like we found root.

In concrete terms I think you are suggesting something like this patch
to follow_dot_dot.

diff --git a/fs/namei.c b/fs/namei.c
index ae4e4c18b2ac..56a8562899a1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1409,6 +1409,11 @@ static void follow_dotdot(struct nameidata *nd)
                        break;
                }
                if (nd->path.dentry != nd->path.mnt->mnt_root) {
+                       /* Escaped path? */
+                       if ((nd->path.mnt->mnt_root != nd->path.mnt->mnt_sb->s_root) &&
+                           d_ancestor(nd->path.mnt->mnt_root, nd->path.dentry))
+                               break;
+                       }
                        /* rare case of legitimate dget_parent()... */
                        nd->path.dentry = dget_parent(nd->path.dentry);
                        dput(old);

> This doesn't have to hook into d_move() and will only trigger the
> "violated" mode on an very specific and rare case.

Am I misunderstanding you?  I don't think .. on a bind mount is a very
specific rare case.

Operations such as following ../../../../../../../../../.. would go from
a cost of O(10) to a cost of O((10*(10 + P + 1))/2) aka
from O(N) to O(N^2+N*P). Where P is the depth of the path below 10
directories up.

Given that in cases like containers bind mounts are frequently the root
mount point of a filesystem I don't think we want that expense, if we
can possibly avoid it.  As that is a DOS attack and messes up
performance for cases that are not afflicected with an escape.

Eric
