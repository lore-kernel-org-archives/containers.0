From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC] c/r: 32-bit support on x86-64
Date: Tue, 26 Jan 2010 15:25:14 -0500
Message-ID: <4B5F4FAA.4040905@cs.columbia.edu>
References: <1264470494-14049-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1264470494-14049-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Applied, thanks.

serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> The first patch is a resend from friday, and should be applied to
> v19.  The second patch I think should be applied to v19 as well,
> as it will prevent accidental attempts to restart a 64-bit image
> with a 32-bit restart, and vice versa.
> 
> The third patch I think does things which need to be done, but
> it doesn't yet get 32-bit restart on x86-64 fully working.  In
> particular, I always get a segfault in VDSO in __kernel_vsyscall().
> What is odd is that the registers seem right, the segfault is at
> the right address, and gdb shows that the right instructions are
> at the faulting address - so the reason for the segfault is still a
> complete mystery to me.
> 
> 
> 
