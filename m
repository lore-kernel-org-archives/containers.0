From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/9] futex.h: fix compat builds
Date: Wed, 16 Sep 2009 12:46:10 -0500
Message-ID: <1253123170.32316.2.camel@localhost.localdomain>
References: <1253091418-14807-1-git-send-email-ntl@pobox.com>
	<1253091418-14807-4-git-send-email-ntl@pobox.com>
	<4AB105F0.4040105@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AB105F0.4040105-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-09-16 at 11:36 -0400, Oren Laadan wrote:
> 
> Nathan Lynch wrote:
> > With any build where CONFIG_COMPAT=y:
> > 
> > checkpoint/process.c: In function 'save_task_robust_futex_list':
> > checkpoint/process.c:37: error: implicit declaration of function 'ptr_to_compat'
> > checkpoint/process.c:38: error: dereferencing pointer to incomplete type
> > checkpoint/process.c: In function 'restore_task_robust_futex_list':
> > checkpoint/process.c:54: error: implicit declaration of function 'compat_ptr'
> > checkpoint/process.c:54: warning: assignment makes pointer from integer without a cast
> > checkpoint/process.c:55: error: implicit declaration of function 'do_compat_set_robust_list'
> > 
> > ptr_to_compat et al need compat.h; however, futex.h is exported while
> > compat.h is not.  So the include is guarded by #ifdef __KERNEL__.
> > 
> > Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> 
> Including futex.h does not require compat.h. Rather, it's the code
> in checkpoint/process.c that uses ptr_to_compat() et al. Is there a
> reason not to include compat.h from checkpoint/process.c instead ?

Oh my, you're right.  I had this hanging around from an older tree where
futex.h did need it, but it's obviously not the right fix now.  The
include should go in checkpoint/process.c.
