From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: bind mounting namespace inodes for unprivileged users
Date: Wed, 04 May 2016 09:16:42 -0400
Message-ID: <1462367802.14310.41.camel@HansenPartnership.com>
References: <1462299656.16133.51.camel@HansenPartnership.com>
	<20160504084403.7z67paycj663lkbt@ws.net.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160504084403.7z67paycj663lkbt-xkT7n84Rsxv/9pzu0YdTqQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Karel Zak <kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2016-05-04 at 10:44 +0200, Karel Zak wrote:
> On Tue, May 03, 2016 at 02:20:56PM -0400, James Bottomley wrote:
> > Right at the moment, unprivileged users cannot call mount --bind to
> > create a permanent copy of any of their namespaces.  This is
> > annoying
> > because it means that for entry to long running containers you have
> > to
> > spawn an undying process and use nsenter via the /proc/<pid>/ns
> > files.
> 
> Well, unshare is able to create permanent namespaces and the bind
> mounts and nsenter is able to follow these files, but you need root
> permissions to create this stuff.
> 
>  touch /home/kzak/ns
>  sudo unshare --uts=/home/kzak/ns
>  <exit namespace>
> 
>  sudo nsenter --uts=/home/kzak/ns
> 
> it means you really do not need any process in the namespace.

Yes, I do this when I'm root.

> Not sure about unprivileged users, it always sounds like a game with
> Pandora's box ;-)

But that's currently my specific problem: binding a container when I'm
an unprivileged user.  I was thinking of persuading mount to do it, but
unshare could as well, provided it's setuid root.  I'm leery of
proliferating setuid root binaries, which is why I was looking at
mount, but I could easily (more easily than mount) make unshare do it
if that's preferred.

James
