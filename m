From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7]: Determine pts_ns from a pty's inode.
Date: Wed, 26 Mar 2008 10:12:05 -0500
Message-ID: <20080326151205.GA16621@sergelap.ibm.com>
References: <20080325035904.GB27451@us.ibm.com>
	<20080325042541.GE27864@us.ibm.com>
	<20080325151705.GE9561@sergelap.austin.ibm.com>
	<20080325211406.GA5817@sergelap.austin.ibm.com>
	<20080326020328.GA11747@us.ibm.com>
	<20080326025038.GA24538@sergelap.austin.ibm.com>
	<20080326145521.GA24292@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080326145521.GA24292-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | > | I suppose you could just create /dev/pts/ptmx and /dev/pts/tty.
> | > | Recommend that in containers /dev/ptmx and /dev/tty be symlinks
> | > | into /dev/pts.  Applications don't need to change.  If
> | > | ptmx_open() sees that inode->i_sb is a devptsfs, it gets the
> | > | namespace from the sb.  If not, then it was a device in /dev
> | > | and it gets the nmespace from current.
> | > 
> | > But we would still depend on user-space remounting /dev/pts after
> | > the clone right ? Until they do that we would access the parent
> | > container's /dev/pts/ptmx ?
> | 
> | Yes.  Which is the right thing to do imo.
> 
> Hmm, that sounds reasonable, although slightly inconsistent with pid-ns,
> where pid starts at 1 regardless of whether /proc is remounted.

Very different cases.  The pid is the task's pid in the new pidns.
The task ALSO has a different pid in the parent pidns.

The pts only has an identity in one ptsns.

> But even so, if user fails to establish the symlink, clones the pts ns
> and tries to create a pty, we would end up with different pts nses again ?

Yes.  So what?

> i.e
> 	/dev/ptmx is still a char dev in root fs
> 	clone(pts_ns)
> 		( In child, (before remount /dev/pts))
> 		open("/dev/ptmx")
> 		open("/dev/pts/0")
> 
> Since ptmx is not in devpts, we use current_pts_ns() or child-pts-ns
> Since /dev/pts is not remounted in child, we get the parent pts-ns from
> 
> If we can somehow detect the incorrect configuration and fail either
> open, we should be ok :-)

I completely disagree with this sentiment.  The kernel doesn't need
to detect an "incorrect configuration" if it isn't dangerous.  One
man's "incorrect configuration" is another man's useful trick.

-serge
