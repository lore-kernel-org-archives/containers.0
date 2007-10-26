From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Devel] [PATCH] pidns: Limit kill -1 and cap_set_all
Date: Fri, 26 Oct 2007 16:10:04 -0600
Message-ID: <m1myu5y1c3.fsf__33511.7183546119$1193436788$gmane$org@ebiederm.dsl.xmission.com>
References: <CBC546DD07068244AEC110EFEDA58B72358940@excite.int.sw-soft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CBC546DD07068244AEC110EFEDA58B72358940-8Cmw1+NI3eM4STc1AIfMP5Z3qXmFLfmx@public.gmane.org>
	(Kir Kolyshkin's message of "Fri, 26 Oct 2007 17:06:54 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
List-Id: containers.vger.kernel.org

"Kir Kolyshkin" <kir-66LJJ20gB3DQT0dZR+AlfA@public.gmane.org> writes:

> Eric, this problem is a known one. Currently Pavel and Sukadev are working on a
> appropriate signal management for namespaces.

I'm fairly certain that the signal issue you they are dealing with
is how to keep children from killing the init of a pid namespace.
At least that is what Suka mentioned when I asked him earlier,
and that is the discussion I have at various times on the containers
list.

This is a totally different issue.  This is keeping
kill -1 in a child pid namespace from sending a signal to
every process in the system.

It is a bad bug and this patch is a complete fix for it.
To my knowledge Pavel and Suka just overlooked this case.

> If you'd first sent this patch for discussion/review to containers@, you'd know
> that the patch is very incomplete.

I explicitly asked Suka, Pavel, and Cedric how complete they thought 
the pid namespace was before I started sending patches.  With
Pavel at a conference it makes sense why he did not reply.

For the most part Suka and Cedric did not know about the issues
that I have been finding and fixing.

So since several of them have been fixable with trivial simple fixes
and because we have passed -rc1 and it is now time for bug fixes
and possibly a few cleanups.  I have been making bug fixes.

Kir I am happy from feedback from people who can understand the code
and patches.  But I am not going to hold up sending simple obviously
correct fixes for discussion.

Eric
