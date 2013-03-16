From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] fs: allow mknod in user namespaces
Date: Fri, 15 Mar 2013 19:23:18 -0500
Message-ID: <20130316002318.GA11997__35946.4654270143$1363393442$gmane$org@sergelap>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<1363338823-25292-4-git-send-email-glommer@parallels.com>
	<87a9q4gzs1.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87a9q4gzs1.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> 
> > Since we have strict control on who access the devices, it should be
> > no problem to allow the device to appear.
> 
> Having cgroups or user namespaces grant privileges makes me uneasy.
> 
> With these patches it looks like I can do something evil like.
> 
> 1. Create a devcgroup.
> 2. Put a process in it.
> 3. Create a usernamespace.
> 4. Run a container in that user namespace.
> 5. As an unprivileged user in that user namespace create another user namespace.
> 6. Call mknod and have it succeed.

not if the devcgroup forbids it.

> Or in short I don't think this handles nested user namespaces at all.
> With or without Serge's suggested change.

Yeah my change doesn't help, other than to stop the unpriv user from
creating the device in an fs he doesn't own...

> At a practical level now is not the right time to be granting more
> permissions to user namespaces.  Lately too many silly bugs have been
> found in what is already there.

I agree.

I realize this doesn't help the centos old-udev situation, but otherwise
bind mounting device files works fine, so I agree we should wait.
Sorry.

-serge
