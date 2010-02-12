From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH user-cr] add -t option to mount new devpts
Date: Fri, 12 Feb 2010 11:05:28 -0600
Message-ID: <20100212170528.GB15333@us.ibm.com>
References: <20091204014347.GA17304@us.ibm.com>
	<4B7582CD.9070900@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B7582CD.9070900-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> Sorry for the late response ...
> 
> Serge E. Hallyn wrote:
> >Trivial patch, and I'm not sure whether we want this or want to
> >do it this way.  But it saves me having to do it during my restart.sh
> >wrapper shell-script.
> 
> This looks useful.
> 
> I wonder if it makes sense to generalize that to allow the user
> to request any mount (and multiple mounts), e.g.
> 	restart --mount="......" --mount="......." ...

Or just a --fstab=some_file option?

> With this switch, 'restart' will create a new mntns and do the
> mounts in it.
> 
> We can then add shortcuts, like --mount-ptys.
> 
> However, I'm concerned about the security implications: ideally
> 'restart' will be setuid executable, so it must be prudent in
> accepting such generic requests as 'mount'.

Hmm, we could use our own mount binary, which is willing to
mount things like devpts and proc as root (since that's completely
private) but otherwise runs the mounts as the original user?  Eventually
do that on top of Miklos' unprivileged-mounts patchset, which will allow
bind mounts on top of dirs/files to which the user has write access.  In
the meantime other mounts would only be allowed if the user was
originally root.

So basically our mount binary would be run with euid=0 and
ruid=suid=N where N is the original userid.

> This last argument is also valid if we stay with this patch,
> because it is racy (time of check to time of use).

Yeah I'm not sure we can solve this right now.  We might be best
off saying that only ruid=0 can do the mounts, and mention something
about setuid-root restart.c can trust TPM-signed checkpoint images.

-serge
