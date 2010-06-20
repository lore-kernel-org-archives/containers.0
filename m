From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [C/R ARM v2][PATCH 0/3] Linux Checkpoint-Restart - ARM port
Date: Sun, 20 Jun 2010 17:34:10 -0400
Message-ID: <4C1E8952.7010503__30138.3183141754$1277069714$gmane$org@cs.columbia.edu>
References: <1272318223-28438-1-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272318223-28438-1-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

Applied.

On 04/26/2010 05:43 PM, Christoffer Dall wrote:
> Following there will be two preparatory patches for an ARM port of the
> checkpoint-restart code and finally a third patch implementing the
> architecture-specific parts of c/r.
> 
> The preparatory patches consist of a partial syscall trace implementation
> for ARM and an eclone implementation for ARM. The syscall trace
> implementation provides only the needed functionality for c/r.
> 
> There is a separate patch for the user space code, which supports
> cross-compilation, extracting headers for ARM and an eclone implementation
> for ARM.
> 
> The kernel patches presented here are based on the ckpt-v21-rc6 patch set.
> 
> ---
> 
> CHANGELOG:
> 
> [2010-Apr-08] v2:
> 	- Systrace implementation now inspects process state to get the
> 	  system call number thereby avoiding extra work on system calls.
> 	- Removed __user attribute on long type in eclone implementation
> 	- Better check for architecture versions across C/R
> 	- Improved checking of user space ABI settings across C/R
> 	- Code simplifications
> 
> [2010-Mar-22] v1:
> 	- Initial version
> 	- Systrace implementation modified the system call entry path to
> 	  store the system call number globally in memory.
> 	- ARM implementation lightly tested
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
