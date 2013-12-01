From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a
	mountpoint
Date: Sun, 1 Dec 2013 15:15:43 +0900
Message-ID: <201312011515.BDE65649.LJQtMFOOSFOFVH__40111.0810497359$1385881195$gmane$org@I-love.SAKURA.ne.jp>
References: <87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
	<20131201050930.GB10323@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131201050930.GB10323-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org
Cc: adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Al Viro wrote:
> On Sat, Nov 30, 2013 at 05:02:26PM +0000, Al Viro wrote:
> 
> > FWIW, the other callers of prepend_path() boil down to /proc/mountinfo
> > handling, apparmour d_namespace_path() (separate handling of MNT_INTERNAL,
> > __d_path() or d_absolute_path() for the rest) and tomoyo_get_absolute_path()
> > (this one directly calls ->d_dname() itself).
> 
> While we are at it, what's the origin of if (buflen >= 256) checks in
> tomoyo_get_absolute_path() and tomoyo_get_dentry_path()?  The minimal
> buflen value they can be called with is PAGE_SIZE - 1.

This is a sanity check in case the caller by error called
tomoyo_get_absolute_path() or tomoyo_get_local_path() with buflen < 2, for
they might accesses buffer[buflen - 2].

But "PAGE_SIZE <= buf_len <= (UINT_MAX + 1) / 2" will be true because doing
buf_len <<= 1 will not make buf_len == 0 since kmalloc((UINT_MAX + 1) / 2)
will return NULL. Therefore, we can ignore/kill "if (buflen >= 256)" check.

Regards.
