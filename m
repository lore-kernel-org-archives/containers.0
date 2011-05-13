From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: acl_permission_check: disgusting performance
Date: Fri, 13 May 2011 09:29:27 -0700
Message-ID: <BANLkTin-9SmqB=U7gmOFY2qkCLNd_Yn-sw__20157.9783497893$1305304324$gmane$org@mail.gmail.com>
References: <BANLkTi=nc3WGaASQm1Pc9byshLOmLf2bXQ@mail.gmail.com>
	<20110513025013.GA13209@mail.hallyn.com>
	<20110513040214.GA25270@mail.hallyn.com>
	<BANLkTim3cy8Jf3URYTW+cbr3nrdWVbsmGw@mail.gmail.com>
	<20110513131904.GA2519@mail.hallyn.com>
	<BANLkTi=yyoMXNqGtVX9KxHjVaDVGW9uzdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <BANLkTi=yyoMXNqGtVX9KxHjVaDVGW9uzdA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Fri, May 13, 2011 at 9:16 AM, Linus Torvalds
<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>
> Looks ok to me. And generates good code for acl_permission_check
> without CONFIG_USER_NS.
>
> I'll see how much that function drops on the kernel profiles..

Yup, looking good.

For my "kernel make with no changes" workload, it dropped from

    1.28%           make  [kernel.kallsyms]             [k] acl_permission_check

to

     0.88%           make  [kernel.kallsyms]             [k]
acl_permission_check

which is pretty much exactly the expected 30% drop from no longer
having that expensive load of user_ns.

Of course, that 30% improvement is just a 0.4% performance improvement
in the big picture, but hey, almost half a percentage point on a real
load from just one single function in the kernel is definitely worth
doing.

Do you want to carry this for 2.6.40, or should I just apply it?

                                Linus
