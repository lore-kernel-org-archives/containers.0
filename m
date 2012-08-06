From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Forbid invocation of kexec_load() outside initial PID
	namespace
Date: Mon, 6 Aug 2012 19:20:40 +0000
Message-ID: <20120806192040.GA27023@mail.hallyn.com>
References: <1343991184-3619-1-git-send-email-berrange@redhat.com>
	<cfa2e2c9-db52-40cd-979b-7a6084427190@email.android.com>
	<20120803125210.GD12870@redhat.com>
	<bef31b2b-429b-4b2b-981b-b230f9c6bfad@email.android.com>
	<1344122135.1422.2.camel@Nokia-N900-51-1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1344122135.1422.2.camel@Nokia-N900-51-1>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> Eric,
> 
> during the container reboot discussion, the agreement was reached that rebooting for real fron non-init pid ns is not safe.  Restarting userspace (in pidns caller owns) is.  I argue the same reasoning supports this.
> 
> I haven't had a chance to review the patch, but the idea gets my ack.  I'll look at the patch asap.
> 
> I'm also fine with splitting cap_sys_boot into a user and system caps.  The former would only be needed targeted to the userns of the init pid, while the latter would be required to init_user_ns.  Then containers could safely be given cap_sys_restart or whatever, but not cap_sys_boot which authorizes kexec and machine reset/poweroff.

Splitting the cap up into CAP_RESTART (restart /sbin/init) and CAP_BOOT
(reboot hardware or kexec kernel) has the advantage that the capabilities
each remain simpler to parse, no 'in this context it means that'.
