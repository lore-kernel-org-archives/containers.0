From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH 6/7]: Check for user-space mount of /dev/pts
Date: Tue, 25 Mar 2008 10:25:45 -0700
Message-ID: <20080325172545.GA3324@us.ibm.com>
References: <20080325035904.GB27451@us.ibm.com>
	<20080325042614.GF27864@us.ibm.com>
	<20080325145448.GC9561@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080325145448.GC9561-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, adobriyan-3ImXcnM4P+0@public.gmane.org, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
| > 
| > From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| > Subject: [PATCH 6/7]: Check for user-space mount of /dev/pts
| > 
| > When the pts namespace is cloned, the /dev/pts is not useful unless it
| > is remounted from the user space.
| > 
| > If user-space clones pts namespace but does not remount /dev/pts, it
| > would end up using the /dev/pts mount from parent-pts-ns but allocate
| > the pts indices from current pts ns.
| 
| So why not use the allocated_ptys from the parent ptsns?  It's what
| userspace asked for and it's safe to do.

The problem is when opening /dev/ptmx, we use current_pts_ns() and
when opening slave-pty, we use pts_ns from the inode.

If child-pts-ns opens /dev/ptmx, we use 'allocated-ptys' from
child-pts-ns and we allocate index 0. But when the process opens
the slave pty "/dev/pts/0", we would get the pts_ns from the
inode which would come from parent-pts-ns (and could refer to
an existing pty).

Agree with Alexey and Pavel, its bad. Will think some more, but
appreciate any ideas.

Sukadev
