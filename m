From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] user-cr: Extract headers from kernel source tree.
Date: Sat, 3 Oct 2009 00:26:04 -0700
Message-ID: <20091003072604.GC18101@count0.beaverton.ibm.com>
References: <1254554424-2979-2-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Oct 03, 2009 at 12:20:25AM -0700, Matt Helsley wrote:
> Using kernel headers directly from userspace is strongly discouraged.
>
> 
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
> 
> Programs should only include linux/checkpoint.h and
> linux/checkpoint_hdr.h. asm/checkpoint_hdr.h is included from
> linux/checkpoint_hdr.h
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org

Note that:

"[PATCH] Fix up headers so we can munge them for use by userspace."

must be applied to the kernel tree before the script in this patch will
reproduce the headers properly. Since this patch includes the necessary
headers synchronizing the transition shouldn't be a problem.

Cheers,
	-Matt
