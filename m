From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 03/11] pidns: Capture the user namespace and filter
	ns_last_pid
Date: Mon, 19 Nov 2012 04:41:39 -0800
Message-ID: <87y5hxahoc.fsf@xmission.com>
References: <50AA259A.5030007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50AA259A.5030007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Zhao Hongjiang's message of "Mon,
	19 Nov 2012 20:27:06 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hi Eric,
>
> I noticed that, the increment refcount of user_ns has never released when the pid_ns's refcount is
> down to zero. And i have sent out a patch to solve this on Nov 2th.
>
> Am i misunderstand something?

No I am.  I have now added your patch to my tree and I hope to post and
updated patchset shortly.  Oops.

Eric
