From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2] cgroups: fix cgroup_event_listener error handling
Date: Tue, 8 Jan 2013 10:08:28 -0800
Message-ID: <20130108180828.GA3926@htj.dyndns.org>
References: <1357333518-28899-1-git-send-email-gthelen@google.com>
	<1357333518-28899-2-git-send-email-gthelen@google.com>
	<20130107174427.GM3926@htj.dyndns.org>
	<xr93a9sklqme.fsf@gthelen.mtv.corp.google.com>
	<50EBBC9C.7060909@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50EBBC9C.7060909-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jan 08, 2013 at 02:28:44PM +0800, Li Zefan wrote:
> > cgroups: fix cgroup_event_listener error handling
> > 
> > The error handling in cgroup_event_listener.c did not correctly deal
> > with either an error opening either <control_file> or
> > cgroup.event_control.  Due to an uninitialized variable the program
> > exit code was undefined if either of these opens failed.
> > 
> > This patch simplifies and corrects cgroup_event_listener.c error
> > handling by:
> > 1. using err*() rather than printf(),exit()
> > 2. depending on process exit to close open files
> > 
> > With this patch failures always return non-zero error.
> > 
> > Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied to cgroup/for-3.9.

Thanks.

-- 
tejun
