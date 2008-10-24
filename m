From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Fri, 24 Oct 2008 08:04:41 +0400
Message-ID: <200810240804.42500.major__2544.47503616593$1224821201$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<200810231354.47033.major@openvz.org>
	<1224769753.12673.12.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224769753.12673.12.camel@nimitz>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday 23 October 2008 17:49 Dave Hansen wrote:
> On Thu, 2008-10-23 at 13:54 +0400, Andrey Mirkin wrote:
> > We are putting special structure on stack, which is used at the very end
> > of the whole restart procedure to restore complex states (ptrace is one
> > of such cases). Right now I don't need to use this structure as we have a
> > deal with simple cases, but reservation of 256 bytes on stack is needed
> > for future.
>
> Wow.  So you're saying that, if this patch is accepted, we simply need
> to accept that anything being checkpointed will use an extra 256 bytes
> of stack?  Seems like something to perhaps put in the changelog rather
> than some completely undocumented assembly nugget.

This 256 bytes will be used only during restart procedure and only by our 
module. As you can see in i386_ret_from_resume we are restoring it back. So, 
when process will return to user space it will not have extra 256 bytes 
reserved on stack already. I will add information about it to documentation 
and changelog.

Andrey
