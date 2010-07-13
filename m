From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] pidns: Fix wait for zombies to be reaped in
	zap_pid_ns_processes
Date: Tue, 13 Jul 2010 17:34:50 -0500
Message-ID: <20100713223450.GA16889__2528.17870718918$1279060509$gmane$org@hallyn.com>
References: <20100625220713.GA31123@us.ibm.com>
	<m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
	<m1mxu15kv4.fsf_-_@fess.ebiederm.org>
	<20100709121425.GB18586@hawkmoon.kerlabs.com>
	<m1lj9k4xfx.fsf@fess.ebiederm.org>
	<20100709141324.GC18586@hawkmoon.kerlabs.com>
	<m1aaq04ph2.fsf_-_@fess.ebiederm.org>
	<20100711141406.GD18586@hawkmoon.kerlabs.com>
	<m1tyo4shas.fsf_-_@fess.ebiederm.org>
	<20100713214234.GA21042@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100713214234.GA21042-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux
List-Id: containers.vger.kernel.org

Quoting Louis Rilling (Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org):
> Hi Eric,
> 
> On 12/07/10 11:09 -0700, Eric W. Biederman wrote:
> This patch looks like it is working (only a small RCU issue shown below). I
> couldn't try it yet though.
> 
> I must admit that I am using a similar back-off solution in Kerrighed (not to
> solve the issue of proc_flush_task(), but for one of the reasons that you stated
> above: we want to be sure that all tasks of the namespace have been reaped), but
> I considered it too ugly to propose it for Linux ;)
> 
> That said, this is probably the least intrusive solution we have seen yet.

Yeah I haven't had a chance to look at it in detail, but this looks
right.  Thanks, Eric.

-serge
