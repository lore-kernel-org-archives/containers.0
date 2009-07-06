From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r tests: Add futex c/r tests
Date: Mon, 6 Jul 2009 18:11:11 -0500
Message-ID: <20090706231111.GA2353@us.ibm.com>
References: <1246910097-30792-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1246910097-30792-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 	Add tests for plain, robust, and pi futexes. Each test sets up a
> typical contended futex scenario and then awaits checkpoint. We only test
> the contended case since the uncontended cases are entirely based on the
> state of userspace memory. After checkpoint each test verifies that the
> critical semantics of the futex still works.

Thanks, Matt, these now compile and run on s390.

> 	For plain futexes we ensure that the same number of tasks that
> were asleep on the futex are woken up.

But plain always returns 0 (success)?

> 	For robust futexes we set the robust list head of each process
> and wait for checkpoint. After checkpoint we verify that the kernel
> still knows about the robust list head then each child exits without
> releasing the futex. Since the child still holds the futex at exit the
> kernel wakes another waiting child.

run.sh doesn't check for the return value.  (trivially fixed as bash
wait returns its return value)

I think you also have several places where you log a FAIL when you should
probably log BROK.  But I've applied this to cr_tests plus a fix
for run.sh to check return values.  Can you send me a fix to have plain.c
log failures (unless I'm misreading and its all fine)?

thanks,
-serge
