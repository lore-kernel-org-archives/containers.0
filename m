From: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] coredump: run the coredump helper using the same
	namespace as the dead process
Date: Mon, 5 Nov 2012 15:18:25 -0500
Message-ID: <20121105201825.GM14789@redhat.com>
References: <20121105163810.GJ14789@redhat.com> <87r4o7alod.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r4o7alod.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Nov 05, 2012 at 11:34:26AM -0800, Eric W. Biederman wrote:
> I would argue that you very much need to define what it means to have a
> per container core dump at the same time as you argue this.
> 
> Nacked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Running in a namespace different than whoever set the core dump
> pattern/helper makes core dump helpers much more attackable.  With this
> patch and a little creativity I expect I can get root to write to
> whatever file I would like.  Since I also control the content of what is
> going into that file.... This design seems emintely exploitable.

Understood. Indeed this is bad design. Having it tied to the mount
namespace of the process setting the pattern/helper, therefore any
process crashing under the same mount namespace would use the same
pattern/helper? 

> Furthermore not all namespaces are pointed at by nsproxy, so even
> for it's original design this patch is buggy.

is it userns? I just assumed it wasn't there yet because it's being
worked on.

> I do think supporting a per container coredump setting makes a lot of
> sense but I do not think this patch is the way to do it.

I understand, thanks for the time reviewing it.


-- 
Aristeu
