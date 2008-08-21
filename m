From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 1/9] kernel based checkpoint-restart
Date: Thu, 21 Aug 2008 01:15:20 -0400
Message-ID: <48ACF9E8.6020203__49746.4510765441$1219296021$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202251500.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org


Subject line should have been 's/PATCH 1/PATCH 0/' ...

I left cr_debug() in for now to provide more info than pr_debug();
eventually that will be changed back to pr_debug()

In the mini-conference we considered doing CR in a kernel module,
but decided against because we needed a system call. It is still
possible to put the bulk of the code in a module. This is useful,
besides reducing debug time (recompile, unload, reload), to reduce
the kernel memory footprint. Also, an administrator can load/unload
the module to enable/disable this feature. Any thoughts ?

Oren.

Oren Laadan wrote:
> 
> These patches implement checkpoint-restart [CR v2]. This version adds
> save and restore of open files state (regular files and directories)
> which makes it more usable. Other changes address the feedback given
> for the previous version. It is also refactored (along Dave's posting)
> for easier reviewing.
> 
> Todo:
> - Add support for x86-64 and improve ABI
> - Refine or change syscall interface
> - Extend to handle (multiple) tasks in a container
> - Security (without CAPS_SYS_ADMIN files restore may fail)
> 
> Changelog:
> 
> [2008-Aug-20] v2:
>   - Added dump and restore of open files (regular and directories);
>     see the changes in the test program (ckpt.c)
>   - Added basic handling of shared objects, and use 'parent tag'
>   - Added documentation
>   - Improved ABI, add 64bit padding for image data
>   - Improved locking when saving/restoring memory
>   - Added UTS information to header (release, version, machine)
>   - Cleanup extraction of filename from a file pointer
>   - Refactor to allow easier reviewing
>   - Remove requirement for CAPS_SYS_ADMIN until we come up with a
>     security policy (this means that file restore may fail)
>   - Other cleanup in response to comments for v1
> 
> [2008-Jul-29] v1:
>   - Initial version: support a single task with address space of only
>     private anonymous or file-mapped VMAs; syscalls ignore pid/crid
>     argument and act on current process.
> 
