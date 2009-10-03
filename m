From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] user-cr: Extract headers from kernel source tree.
Date: Sat, 03 Oct 2009 16:40:41 -0500
Message-ID: <1254606041.2928.3.camel@localhost.localdomain>
References: <1254554424-2979-2-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254554424-2979-2-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Sat, 2009-10-03 at 00:20 -0700, Matt Helsley wrote:
> Sanitize kernel headers for userspace by extracting non-__KERNEL__
> portions of the various checkpoint headers and placing them in a
> similar organization of userspace headers.
> 
> The script is run from the top level of the user-cr source tree like:
> 
> 	./scripts/extract-headers.sh -s <path-to-kern-source> -o ./include
> 
> The patch includes a copy of the auto-generated headers and adjusts
> the user-cr programs to use them.

I appreciate the effort put into this, but why isn't the
"headers_install" target of the kernel Makefile sufficient to produce
headers that are usable by userspace?  So far as I know, other projects
with complex kernel/user interfaces (e.g. kvm) haven't had to resort to
special-purpose programs like this.
