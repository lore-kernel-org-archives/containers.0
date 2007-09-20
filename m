From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Kernel text size with pid namespace
Date: Thu, 20 Sep 2007 15:55:01 +0400
Message-ID: <46F25F95.8000103@openvz.org>
References: <20070920001644.GA14880@us.ibm.com>	<46F239B2.8080500@openvz.org>
	<20070920040406.57e40ece.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070920040406.57e40ece.pj-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Jackson wrote:
>>> functions are used in process creation/termination, we would need to
>>> keep them inline, when optimizing for performance.
>> I'd keep them inline for performance reasons.
> 
> As Matt Mackall explained more carefully in his reply, it's no longer
> clear that inlining is best for performance in as many situations as
> it was the past.  Cache footprint size tends to dominate performance on
> present day processors.

True, but AFAIR, when I developed the namespaces I tried to move
the task_pid_nr etc calls in kernel/pid.c and the performance on
unixbench spawn and nptlperf tests became worse. That's why I said
that I'd keep them inline.

> See also Matt's comments on the NULL struct pid check.  Getting rid
> of conditional jumps may be the more important performance issue here.

That's a valid argument. I will look over it.

Thanks,
Pavel
