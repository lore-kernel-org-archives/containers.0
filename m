From: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] proc: #68991 Fix GPF in /proc/$PID/map_files
Date: Fri, 7 Mar 2014 18:45:00 +0400
Message-ID: <20140307144500.GI1852@moon>
References: <20140308022033.GC5690@owamsq.epam.com>
	<5319D7B9.6050000@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5319D7B9.6050000-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, alexandr_terekhov-uRwfk40T5oI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Artem Fetishev <artem_fetishev-uRwfk40T5oI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 07, 2014 at 06:29:13PM +0400, Pavel Emelyanov wrote:
> On 03/08/2014 06:20 AM, Artem Fetishev wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=68991
> > 
> > The expected logic of proc_map_files_get_link() is either to return 0 and
> > initialize 'path' or return an error and leave 'path' uninitialized. By the time
> > dname_to_vma_addr() returns 0 the corresponding vma may have already be gone. In
> > this case the path is not initialized but the return value is still 0. This
> > results in 'general protection fault' inside d_path().
> > 
> > Steps to reproduce:
> > CONFIG_CHECKPOINT_RESTORE=y
> > 
> > fd = open(...);
> > while (1) {
> > 	mmap(fd, ...);
> > 	munmap(fd, ...);
> > }
> > 
> > ls -la /proc/$PID/map_files
> > 
> > Signed-off-by: Artem Fetishev <artem_fetishev-uRwfk40T5oI@public.gmane.org>
> > Signed-off-by: Aleksandr Terekhov <aleksandr_terekhov-uRwfk40T5oI@public.gmane.org>
> 
> Acked-by: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Good catch, thanks!

Acked-by: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

I suppose this is a stable@ material.
