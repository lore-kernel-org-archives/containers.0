From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/7][v2] Cloning PTS namespace
Date: Tue, 25 Mar 2008 10:51:15 +0300
Message-ID: <47E8AEF3.4060406@openvz.org>
References: <20080325035904.GB27451@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080325035904.GB27451-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Devpts namespace patchset
> 
> In continuation of the implementation of containers in mainline, we need to
> support multiple PTY namespaces so that the PTY index (ie the tty names) in
> one container is independent of the PTY indices of other containers.  For
> instance this would allow each container to have a '/dev/pts/0' PTY and
> refer to different terminals.
> 
> 	[PATCH 1/7]: Propagate error code from devpts_pty_new
> 	[PATCH 2/7]: Factor out PTY index allocation
> 	[PATCH 3/7]: Enable multiple mounts of /dev/pts
> 	[PATCH 4/7]: Implement get_pts_ns() and put_pts_ns()
> 	[PATCH 5/7]: Determine pts_ns from a pty's inode.
> 	[PATCH 6/7]: Check for user-space mount of /dev/pts
> 	[PATCH 7/7]: Enable cloning PTY namespaces
> 
> Todo:
> 	- This patchset depends on availability of additional clone flags.
> 	  and relies on on Cedric's clone64 patchset.

But this set was not even reviewed, wasn't it? Does anybody
know what are the plans about exhausted flags?

Thanks,
Pavel
