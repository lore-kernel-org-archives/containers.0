From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: acl_permission_check: disgusting performance
Date: Thu, 12 May 2011 20:52:05 -0700
Message-ID: <m1iptf1cm2.fsf__20960.3934469216$1305258902$gmane$org@fess.ebiederm.org>
References: <BANLkTi=nc3WGaASQm1Pc9byshLOmLf2bXQ@mail.gmail.com>
	<20110513025013.GA13209@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110513025013.GA13209-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Thu, 12 May 2011 21:50:13 -0500")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Linus Torvalds (torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
>> Those four instructions are about two thirds of the cost of the
>> function. The last two are about 50% of the cost.
>> 
>> They are the accesses to "current", "->cred", "->user" and "->user_ns"
>> respectively (the cmp with the big constant is that compare against
>> "init_ns").
>> 
>> Now, if we got rid of them, we wouldn't improve performance by 2/3rds
>> on that function, because we do need the two first accesses for
>> "fsuid" (which is the next check), and the third one (which is
>> currently "cred->user" ends up doing the cache miss that we'd take for
>> "cred->fsuid" anyway. So the first three costs are fairly inescapable.
>> 
>> They are also cheaper, probably because those fields tend to be more
>> often in the cache. So it really is that fourth one that hurts the
>> most, as shown by it taking almost a third of the cycles of that
>> function.
>> 
>> And it all comes from that annoying commit e795b71799ff0 ("userns:
>> userns: check user namespace for task->file uid equivalence checks"),
>> and I bet nobody involved thought about how expensive that was.
>> 
>> That "user_ns" is _really_ expensive to load. And the fact that it's
>> after a chain of three other loads makes it all totally serialized,
>> and makes things much more expensive.
>> 
>> Could we perhaps have "user_ns" directly in the "struct cred"? Or
>
> The only reason not to put it into struct cred would be to avoid growing
> the struct cred.  For that matter, esp since you can't unshare the user_ns,
> it could also go right into the task_struct.
>
> (Eric's sys_setns patchset will eventually complicate that, but I don't
> think it'll be a problem)

From the perspective of a process the user namespace and the pid
namespace will never change.  I expect we will have something that lets
you change the user namespace and the pid namespace experienced by child
processes.  So the sys_setns work should not affect this.

>> could we avoid or short-circuit this check entirely somehow, since it
>> always checks against "init_ns"?
>
> Of course I'm hoping that before fall the check won't be against
> init_ns any more :)  I was actually hoping to get back to that next
> week, so I can start by testing the caching you suggest.

Linus brings up a good point that we need to be very careful with
the user namespace and performance.  That said I think there is
a cheap trick we can do until the user namespace is actually
good for something.

Something like my untested patch below.

Perhaps current_user_ns needs to move into user_namespace.h to get this
to compile.  There are some weird circular header dependencies in there.

In any event an inline version of current_user_ns that returns
init_user_ns in the case where user namespaces aren't compiled in should
fix the immediate performance problems by allowing the compiler to
optimize them out.

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 9aeeb0b..09c76c2 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -357,7 +357,17 @@ static inline void put_cred(const struct cred *_cred)
 #define _current_user_ns()	(current_cred_xxx(user)->user_ns)
 #define current_security()	(current_cred_xxx(security))
 
+#if CONFIG_USER_NS
 extern struct user_namespace *current_user_ns(void);
+#else
+struct user_namespace;
+extern struct user_namespace init_user_ns;
+static inline struct user_namespace *current_user_ns(void)
+{
+
+	return &init_user_ns;
+}
+#endif
 
 #define current_uid_gid(_uid, _gid)		\
 do {						\
