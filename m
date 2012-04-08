From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 0/43] Completing the user namespace
Date: Sun, 08 Apr 2012 15:52:15 -0700
Message-ID: <m1zkaldeg0.fsf__29734.1345613406$1333925320$gmane$org@fess.ebiederm.org>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<CAFLxGvwyx6S6+eZtR=UNSQe_O+W7oZW=GosseL54HGpjtYGXjg@mail.gmail.com>
	<m1iph9ewsy.fsf@fess.ebiederm.org>
	<CAFLxGvwHtA028V2XudM-5HXmXCPw5ENL5E_nHKZh_gbrsRV69g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFLxGvwHtA028V2XudM-5HXmXCPw5ENL5E_nHKZh_gbrsRV69g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(richard's message of "Mon, 9 Apr 2012 00:04:56 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Sun, Apr 8, 2012 at 11:30 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
> Yep. Sounds great!
> I'll give your patch set a try within the next few days on my LXC
> testbed. :-)

Sounds good.

The big practical detail to work out is all of the userspace bits for
the uid and gid mappings.  Assigning multiple uids per each user and
things like that.  Which I expect ultimately means updating the shadow
package to set it up so that we reserve a bunch of uids and gids for
each user when their accounts are added.

Eric
